# Firebase Setup and User Authentication

## Introduction
Firebase [[1](https://firebase.google.com/)] is a free and unified app development platform that features a suite of user-friendly tools to deploy robust and scalable applications. Most notably, Firebase supports real-time databases with built-in user authentication, web hosting, and storage that is used as a comprehensive Backend-as-a-service (BaaS). Its wide array of Software Development Kits (SDKs) and broad cross-platform support makes Firebase the ideal choice for developers to write full-stack applications with minimal backend code.

## Why Firebase?
Firebase is most recognized for its unique cloud-hosted real-time database. Unlike traditional databases that require the user to refresh to pull new data, Firebase automatically synchronizes all clients with the latest data&mdash;an absolutely essential element of any low-latency real-time collaborative application. 

Furthermore, Firebase utilizes an event-driven architechture with asynchronous requests that eliminate the need for regular polling to communicate with the server. In fact, this underlying architechture was designed to be highly scalable for a large number of concurrent users, all while remaining performant. Firebase also utilizes websockets to maximize security and leverages the local cache to provide robust offline support that allows the application to function seemlessly despite an abrput loss of connection.

But the benefits don't end there. Since Firebase stores all of your data as a json file, communicating with the server is as easy as sending an HTTP request. Thanks to this easy-to-use and streamlined process, developers can forego the complexities of maintaining a backend infrastructure, and instead focus on the front-end or application itself. And of course, for your average project, Firebase is completely free.

## Getting Started
This tutorial leverages Firebase's user-friendly setup and detailed documentation [[2](https://firebase.google.com/docs)] to host a simple website that supports email and password user authentication. This guide assumes familiarity with Javascript and html, but should be easy to follow nonetheless.

### Setup
We begin by creating a new Firebase project:

1. Navigate to https://console.firebase.google.com/ and click "Create a Project"
2. Choose a name for your project and accept the necessary conditions.
3. Click Build -> Authentication -> Get Started and choose a sign-in provider
4. Click Build -> Realtime Database -> Create Database
5. Choose a desired location and choose locked mode
6. Click project settings -> click the web app symbol and register a web app
7. Select "use npm" and copy the script and Firebase configuration to be used later

Install Node package manager from https://nodejs.org/en/download/current 

Install Firebase using npm:
```sh
npm install -g firebase-tools
```
Navigate to your project directory and sign in with the same google account you used to create the Firebase project by running,
```sh
firebase login
```
Run the following command and select "Use an existing project" and choose the Firebase project we created.
```sh
firebase init hosting
```

Choose the desired public directory, do not configure as a single page-app, and do not set up automatic builds and deploys with Github.

Run the following command and visit the url http://localhost:5002 
```sh
firebase serve
```

Edit the `index.html` as follows, pasting in the script tag from Project settings. Ensure that the urls are `app.js`, `auth.js`, and `database.js`. Refresh the url to see the changes at any given time.
```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Firebase Login</title>
    <link rel="stylesheet" href="index.css">
  </head>
  <body>
      <div id="container">
          <div id="header_container">
              <h2 id="header"> Firebase Login </h2>
          </div>
          <div id="login_container">
              <input type="email" id="email" placeholder="Email">
              <input type="password" id="password" placeholder="Password">

              <div id="button_container">
                  <button onclick="login()">Login</button>
                  <button onclick="register()">Register</button>
              </div>
          </div>
    </div>
  </body>
  <script src="https://www.gstatic.com/firebasejs/10.8.0/firebase-app.js"></script>
  <!-- TODO: Add SDKs for Firebase products that you want to use
        https://firebase.google.com/docs/web/setup#available-libraries -->
  <script src="https://www.gstatic.com/firebasejs/10.8.0/firebase-auth.js"></script>
  <script src="https://www.gstatic.com/firebasejs/10.8.0/firebase-database.js"></script>
  <!-- Our script must be loaded after firebase references -->
  <script src="index.js"></script>
</html>

```
Create a file `index.js` in the same directory as `index.html` and paste in the config from Project settings.
```javascript
// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyBd3IrlzXFiR0EbR55RJ9tOyt24nHOaqa8",
  authDomain: "da-cf67c.firebaseapp.com",
  databaseURL: "https://da-cf67c-default-rtdb.firebaseio.com",
  projectId: "da-cf67c",
  storageBucket: "da-cf67c.appspot.com",
  messagingSenderId: "191497587079",
  appId: "1:191497587079:web:9668d21d7a769ae30d2b22",
  measurementId: "G-KK54Z58YL5"
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig)
const auth = firebase.auth()
const database = firebase.database()
```

We create a function to verify that the input email is in the correct format using regex.
```javascript
// Validate Email
function validate_email(email) {
    expression = /^[^@]+@\w+(\.\w+)+\w$/
    if (expression.test(email) == true) {
      // Email is good
      return true
    } else {
      // Email is not good
      return false
    }
}
```
We add the register function.
```javascript
// Register Function
function register () {
    email = document.getElementById('email').value
    password = document.getElementById('password').value
    // Validate Email
    if (validate_email(email) == false) {
        alert('Invalid Email')
        return
    }
}
```
We add the following code within the register function to proceed with the authentication
```javascript
// User Authentication
auth.createUserWithEmailAndPassword(email, password).then(function() {
  var user = auth.currentUser
  // Add User to Database
  var database_ref = database.ref()

  // Create User data
  var user_data = {
    email : email,
    last_login : Date.now()
  }
  // Push to Firebase Database
  database_ref.child('users/' + user.uid).set(user_data)
  alert('User Registered')
}).catch(function(error) {
  var error_message = error.message
  alert(error.message)
})
```

We create the Login Function
```javascript
// Login Function
function login () {
    // Get all our input fields
    email = document.getElementById('email').value
    password = document.getElementById('password').value
  
    // Validate Email
    if (validate_email(email) == false) {
        alert('Invalid Email')
        return
    }
}
```

We add the following code within the login function to proceed with the authentication
```javascript
auth.signInWithEmailAndPassword(email, password)
.then(function() {
  var user = auth.currentUser
  // Add User to Database
  var database_ref = database.ref()

  // Create User data
  var user_data = {
    last_login : Date.now()
  }
  // Push to Firebase Database
  database_ref.child('users/' + user.uid).update(user_data)
  // DOne
  alert('User Logged In!!')
}).catch(function(error) {
  alert(error.message)
})
```

In the Firebase project, click Realtime Database -> Rules and paste the following:
```javascript
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    }
  }
}
```

Now deploy the server
```javascript
firebase deploy
```

## Conclusion
Any real-time multiplayer activity requires constant updates of data and synchronization between all clients. Firebase is an excellent choice for an secure, real-time, and highly performant database and backend to meet those needs. With only a few lines of code, you can deploy a fully functional web app with user authentication and store any data for free, which makes Firebase the ideal backend provider for most projects.