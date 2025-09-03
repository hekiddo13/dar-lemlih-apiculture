import React from 'react';
import ReactDOM from 'react-dom/client';
import MinimalApp from './MinimalApp';

const root = document.getElementById('root');
if (root) {
  ReactDOM.createRoot(root).render(
    <React.StrictMode>
      <MinimalApp />
    </React.StrictMode>
  );
} else {
  document.body.innerHTML = '<h1>No root element found!</h1>';
}
