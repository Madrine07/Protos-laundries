importScripts("https://www.gstatic.com/firebasejs/12.9.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/12.9.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyCRqa1rsGRehlK8go9jUNS3aAUECeHBkY4",
  authDomain: "protos-laundries.firebaseapp.com",
  projectId: "protos-laundries",
  storageBucket: "protos-laundries.firebasestorage.app",
  messagingSenderId: "364294517278",
  appId: "1:364294517278:web:ebef389ba1b472bf09340f",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  console.log('Background message received:', payload);
  
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});