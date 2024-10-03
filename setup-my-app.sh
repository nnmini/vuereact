#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Define project name
PROJECT_NAME="my-app"

# Create project directory
mkdir $PROJECT_NAME
cd $PROJECT_NAME

# Initialize package.json
npm init -y

# Install dependencies
npm install react react-dom vue @okta/okta-auth-js @okta/okta-react @okta/okta-vue single-spa single-spa-react single-spa-vue webpack webpack-cli webpack-dev-server babel-loader @babel/core @babel/preset-env @babel/preset-react vue-loader vue-template-compiler css-loader style-loader html-webpack-plugin systemjs-webpack-interop

# Install development dependencies
npm install --save-dev @babel/plugin-transform-runtime @babel/runtime

# Create directory structure
mkdir -p public src/react src/vue src/auth

# Create public/index.html
cat > public/index.html <<EOL
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Vue and React with Okta</title>
</head>
<body>
  <div id="root"></div>
  <script src="bundle.js"></script>
</body>
</html>
EOL

# Create src/react/ReactApp.jsx
cat > src/react/ReactApp.jsx <<EOL
import React from 'react';
import { useOktaAuth } from '@okta/okta-react';

const ReactApp = () => {
  const { authState, authService } = useOktaAuth();

  if (!authState.isAuthenticated) {
    authService.login('/');
    return null;
  }

  return (
    <div>
      <h1>Hello React</h1>
    </div>
  );
};

export default ReactApp;
EOL

# Create src/vue/VueApp.vue
cat > src/vue/VueApp.vue <<EOL
<template>
  <div>
    <h1>Hello Vue</h1>
  </div>
</template>

<script>
import { useOktaAuth } from '@okta/okta-vue';

export default {
  name: 'VueApp',
  setup() {
    const { authState, authService } = useOktaAuth();

    if (!authState.isAuthenticated) {
      authService.login('/');
    }
  },
};
</script>

<style scoped>
/* Add your styles here */
</style>
EOL

# Create src/auth/OktaAuth.js
cat > src/auth/OktaAuth.js <<EOL
// src/auth/OktaAuth.js
import { OktaAuth } from '@okta/okta-auth-js';

const oktaAuth = new OktaAuth({
  issuer: 'https://{yourOktaDomain}/oauth2/default',
  clientId: '{yourClientId}',
  redirectUri: window.location.origin + '/login/callback',
});

export default oktaAuth;
EOL

# Create src/router.js
cat > src/router.js <<EOL
// src/router.js
import { registerApplication, start } from 'single-spa';
import singleSpaReact from 'single-spa-react';
import singleSpaVue from 'single-spa-vue';
import React from 'react';
import ReactDOM from 'react-dom';
import Vue from 'vue';
import VueApp from './vue/VueApp.vue';
import ReactApp from './react/ReactApp.jsx';
import oktaAuth from './auth/OktaAuth';

// Register Vue App
registerApplication({
  name: 'vue-app',
  app: () => Promise.resolve({
    bootstrap: [() => Promise.resolve()],
    mount: () => {
      new Vue({
        render: h => h(VueApp),
      }).\$mount('#vue');
      return Promise.resolve();
    },
    unmount: () => {
      const vueInstance = Vue.prototype.\$vueInstance;
      if (vueInstance) {
        vueInstance.\$destroy();
      }
      return Promise.resolve();
    },
  }),
  activeWhen: ['/vue'],
});

// Register React App
registerApplication({
  name: 'react-app',
  app: () => Promise.resolve({
    bootstrap: [() => Promise.resolve()],
    mount: () => {
      ReactDOM.render(<ReactApp />, document.getElementById('react'));
      return Promise.resolve();
    },
    unmount: () => {
      ReactDOM.unmountComponentAtNode(document.getElementById('react'));
      return Promise.resolve();
    },
  }),
  activeWhen: ['/react'],
});

// Start single-spa
start();
EOL

# Create src/index.js
cat > src/index.js <<EOL
// src/index.js
import { setPublicPath } from 'systemjs-webpack-interop';
setPublicPath('@my-app');

import './router';
import oktaAuth from './auth/OktaAuth';

// Initialize Okta Authentication
oktaAuth.token.getWithRedirect({
  responseType: 'token id_token',
  scopes: ['openid', 'profile', 'email'],
});
EOL

# Create webpack.config.js
cat > webpack.config.js <<EOL
// webpack.config.js
const path = require('path');
const { VueLoaderPlugin } = require('vue-loader');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
  entry: './src/index.js',
  output: {
    filename: 'bundle.js',
    path: path.resolve(__dirname, 'public'),
    publicPath: '/',
  },
  resolve: {
    extensions: ['.js', '.jsx', '.vue'],
  },
  module: {
    rules: [
      {
        test: /\.vue$/,
        loader: 'vue-loader',
      },
      {
        test: /\.jsx?$/,
        exclude: /node_modules/,
        use: 'babel-loader',
      },
      {
        test: /\.css$/,
        use: ['style-loader', 'css-loader'],
      },
    ],
  },
  plugins: [
    new VueLoaderPlugin(),
    new HtmlWebpackPlugin({
      template: './public/index.html',
    }),
  ],
  devServer: {
    historyApiFallback: true,
    static: path.join(__dirname, 'public'),
    port: 8080,
  },
  optimization: {
    splitChunks: {
      chunks: 'all',
    },
  },
};
EOL

# Create .babelrc
cat > .babelrc <<EOL
{
  "presets": [
    "@babel/preset-env",
    "@babel/preset-react"
  ],
  "plugins": [
    "@babel/plugin-transform-runtime"
  ]
}
EOL

# Update package.json scripts
npm set-script build "webpack --mode production"
npm set-script start "webpack serve --mode development"

# Display completion message
echo "Project setup complete!"

echo "Next steps:
1. Replace '{yourOktaDomain}' and '{yourClientId}' in src/auth/OktaAuth.js with your Okta credentials.
2. Run 'npm start' to launch the development server.
3. Navigate to 'http://localhost:8080/vue' for the Vue page and 'http://localhost:8080/react' for the React page.
"

