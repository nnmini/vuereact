// src/react/ReactApp.jsx
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