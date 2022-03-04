let key;
let amount;
let razorpayOrderId;
let orderId;
let receipt;
let color;
let storeName;
let name;
let email;
let contactNumber;
let options;
let rzpButton;
let orderToken;
let currency;
let frontend;
let successCallbackPath;

const paymentFailed = (response) => {
  alert(response.error.code);
  alert(response.error.description);
  alert(response.error.source);
  alert(response.error.step);
  alert(response.error.reason);
  alert(response.error.metadata.order_id);
  alert(response.error.metadata.payment_id);
};

const setPaymentMethod = () => {
  if (frontend === 'true') {
    paymentMethodId = document.querySelector('[name="order[payments_attributes][][payment_method_id]"]:checked').value
  } else {
    paymentMethodId = document.querySelector('[name="payment[payment_method_id]"]:checked').value
  }
}

const intializeCheckout = () => {
  setPaymentMethod();
  const body = JSON.stringify({
    receipt: receipt,
    amount: amount,
    orderId: orderId,
    paymentMethodId: paymentMethodId
  });

  return fetch('/api/initialize_checkout', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      "X-Spree-Order-Token": orderToken
    },
    body
  })
}

const paymentSuccess = async (data) => {
  let floatAmount = (Number.parseFloat(amount) * 0.01).toPrecision(4)

  const body = JSON.stringify({
    order_token: orderToken,
    payment: {
      amount: floatAmount,
      payment_method_id: paymentMethodId,
      source_attributes: {
        razorpay_order_id: razorpayOrderId,
        razorpay_payment_id: data.razorpay_payment_id
      }
    },
  });

  return resp = await fetch('/api/checkouts/' + receipt + '/payments', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      "X-Spree-Order-Token": orderToken
    },
    body,
  });
}

const advanceOrder = async () => {
  return fetch('/api/checkouts/' + receipt + '/advance', {
    method: "PUT",
    headers: {
      'Content-Type': 'application/json',
      "X-Spree-Order-Token": orderToken
    },
    data: {
      order_token: orderToken
    }
  })
}

document.addEventListener('DOMContentLoaded', () => {
  rzpButton = document.getElementById('rzp-button1');
  if(rzpButton) {
    amount = rzpButton.dataset.amount;
    receipt = rzpButton.dataset.receipt;
    currency = rzpButton.dataset.currency;
    storeName = rzpButton.dataset.storeName;
    name = rzpButton.dataset.name;
    email = rzpButton.dataset.email;
    contactNumber = rzpButton.dataset.contactNumber;
    orderToken = rzpButton.dataset.orderToken;
    orderId = rzpButton.dataset.orderId;
    frontend = rzpButton.dataset.frontend;
    successCallbackPath = rzpButton.dataset.successCallbackPath;

    options = {
      "key": '',
      "amount": amount,
      "currency": currency,
      "name": storeName,
      "order_id": '',
      "handler": async function (response) {
          // Call Payment API to create payment source for order and update status
          await paymentSuccess(response);
          await advanceOrder();
          if (frontend) {
            window.location.href = successCallbackPath;
          }
      },
      "prefill": {
          "name": name,
          "email": email,
      },
    };

    rzpButton.onclick = async function(e) {
      e.preventDefault()
      // CAll API to create Razorpay Order
      intializeCheckout()
      .then((resp) => resp.json())
      .then((response) => {
        options.order_id = razorpayOrderId = response.razorpayOrderId;
        options.key = response.razorpayKey;
      })
      .then(() => {
        let rzp1 = new Razorpay(options);
        rzp1.on('payment.failed', (response) => paymentFailed(response));
        rzp1.open()
      });
    }
  }
});
