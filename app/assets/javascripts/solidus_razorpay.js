let key;
let amount;
let currency;
let orderId;
let receipt;
let color;
let storeName;
let name;
let email;
let contactNumber;
let options;
let rzpButton;

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
  return fetch('/razorpay_order' + '?receipt=' + receipt + '&amount=' + amount, { method: 'GET' })
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

    options = {
      "key": key,
      "amount": amount,
      "currency": currency,
      "name": storeName,
      "order_id": '',
      "handler": function (response){
          // Call Payment API to create payment source for order and update status
          console.log(response);
          alert(response.razorpay_payment_id);
          alert(response.razorpay_order_id);
          alert(response.razorpay_signature)
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
      .then((response) => response.orderId)
      .then((orderId) => options.order_id = orderId)
      .then(() => {
        let rzp1 = new Razorpay(options);
        rzp1.on('payment.failed', (response) => paymentFailed(response));
        rzp1.open()
      });
    }
  }
});
