let key;
let amount;
let currency;
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
let paymentSourceId;
let frontend;

const paymentFailed = (response) => {
  alert(response.error.code);
  alert(response.error.description);
  alert(response.error.source);
  alert(response.error.step);
  alert(response.error.reason);
  alert(response.error.metadata.order_id);
  alert(response.error.metadata.payment_id);
};

const createOrder = () => {
  const body = JSON.stringify({
    receipt: receipt,
    amount: amount,
    orderId: orderId
  });

  return fetch('/razorpay_order', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      "X-Spree-Order-Token": orderToken
    },
    body
  })
}

const paymentSuccess = async (data) => {
  let paymentMethodId;
  let floatAmount = (Number.parseFloat(amount) * 0.01).toPrecision(4)

  if (frontend) {
    paymentMethodId = document.querySelector('[name="order[payments_attributes][][payment_method_id]"]:checked').value
  } else {
    paymentMethodId = document.querySelector('[name="payment[payment_method_id]"]:checked').value
  }

  const body = JSON.stringify({
    order_token: orderToken,
    payment: {
      amount: floatAmount,
      payment_method_id: paymentMethodId,
      source_attributes: {
        order_id: orderId,
        razorpay_order_id: razorpayOrderId,
        razorpay_payment_id: data.razorpay_payment_id,
        razorpay_signature: data.razorpay_signature
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
  console.log('Razorpay JS Loaded');
  rzpButton = document.getElementById('rzp-button1');
  if(rzpButton) {
    key = rzpButton.dataset.key;
    amount = rzpButton.dataset.amount;
    currency = rzpButton.dataset.currency;
    receipt = rzpButton.dataset.receipt;
    color = rzpButton.dataset.color;
    storeName = rzpButton.dataset.storeName;
    name = rzpButton.dataset.name;
    email = rzpButton.dataset.email;
    contactNumber = rzpButton.dataset.contactNumber;
    orderToken = rzpButton.dataset.orderToken;
    orderId = rzpButton.dataset.orderId;
    frontend = rzpButton.dataset.frontend

    options = {
      "key": key,
      "amount": amount,
      "currency": currency,
      "name": storeName,
      "order_id": '',
      "handler": async function (response) {
          // Call Payment API to create payment source for order and update status
          await paymentSuccess(response);
          await advanceOrder();
          if (frontend) {
            window.location.href = '/checkout/confirm';
          }
      },
      "prefill": {
          "name": name,
          "email": email,
          "contact": contactNumber
      },
      "theme": {
          "color": color
      },
      config: {
        display: {
          blocks: {
            banks: {
              name: 'All payment methods',
              instruments: [
                {
                  method: 'upi'
                },
                {
                  method: 'card'
                },
                {
                  method: 'wallet'
                },
                {
                  method: 'netbanking'
                },
                {
                  method: 'emi'
                }
              ],
            },
          },
          sequence: ['block.banks'],
          preferences: {
            show_default_blocks: false,
          },
        },
      }
    };
  
    rzpButton.onclick = async function(e) {
      e.preventDefault()
      // CAll API to create Razorpay Order
      createOrder()
      .then((resp) => resp.json())
      .then((response) => {
        options.order_id = razorpayOrderId = response.razorpayOrderId;
        paymentSourceId = response.paymentSourceId;
      })
      .then(() => {
        let rzp1 = new Razorpay(options);
        rzp1.on('payment.failed', (response) => paymentFailed(response));
        rzp1.open()
      });
    }
  }
});
