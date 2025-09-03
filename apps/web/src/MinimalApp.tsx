import React from 'react';

export default function MinimalApp() {
  return (
    <div style={{ padding: '20px', fontFamily: 'Arial' }}>
      <h1>Dar Lemlih - Minimal Version</h1>
      <p>If you see this, React is working!</p>
      <hr />
      <h2>Debug Info:</h2>
      <ul>
        <li>React: ✅ Working</li>
        <li>App rendered at: {new Date().toLocaleTimeString()}</li>
      </ul>
    </div>
  );
}
