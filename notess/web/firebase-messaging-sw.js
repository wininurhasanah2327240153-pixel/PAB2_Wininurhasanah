importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js");

// Gunakan konfigurasi web dari firebase_options.dart Anda
firebase.initializeApp({
    apiKey: 'AIzaSyDIYgKMX3PE43Uq6ennyYw4uHlim-Vis90',
    appId: '1:756781367271:web:cf797a9289b434e452c742',
    messagingSenderId: '756781367271',
    projectId: 'notess-2a985',
    authDomain: 'notess-2a985.firebaseapp.com',
    storageBucket: 'notess-2a985.firebasestorage.app',
    measurementId: 'G-YP1FFB5MY3',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: "/favicon.png",
  };
  return self.registration.showNotification(notificationTitle, notificationOptions);
});
