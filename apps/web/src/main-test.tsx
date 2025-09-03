import React from 'react'
import ReactDOM from 'react-dom/client'
import './index.css'

const TestApp = () => {
  return (
    <div style={{ padding: '20px', fontFamily: 'system-ui' }}>
      <h1>Dar Lemlih Apiculture - Test Mode</h1>
      <p>If you can see this, React is working! ✅</p>
      <div style={{ marginTop: '20px', padding: '10px', background: '#f0f0f0', borderRadius: '8px' }}>
        <h2>System Status:</h2>
        <ul>
          <li>✅ React loaded</li>
          <li>✅ ReactDOM loaded</li>
          <li>✅ App rendered</li>
        </ul>
      </div>
      <div style={{ marginTop: '20px' }}>
        <button 
          onClick={() => alert('Button works!')}
          style={{ 
            padding: '10px 20px', 
            background: '#10b981', 
            color: 'white', 
            border: 'none',
            borderRadius: '6px',
            cursor: 'pointer'
          }}
        >
          Test Interactivity
        </button>
      </div>
    </div>
  )
}

const root = document.getElementById('root')
if (!root) {
  document.body.innerHTML = '<div style="color: red; padding: 20px;">Error: Root element not found!</div>'
} else {
  try {
    ReactDOM.createRoot(root).render(
      <React.StrictMode>
        <TestApp />
      </React.StrictMode>
    )
    console.log('✅ App rendered successfully!')
  } catch (error) {
    console.error('❌ Failed to render app:', error)
    root.innerHTML = `<div style="color: red; padding: 20px;">Error: ${error}</div>`
  }
}
