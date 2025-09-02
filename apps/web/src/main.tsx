import React from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import './index.css'
import './i18n'
import App from './shell/App'

const root = document.getElementById('root')
if (!root) {
  console.error('Root element not found!')
} else {
  try {
    ReactDOM.createRoot(root).render(
      <React.StrictMode>
      <BrowserRouter>
          <App />
        </BrowserRouter>
      </React.StrictMode>
    )
  } catch (error) {
    console.error('Failed to render app:', error)
    root.innerHTML = '<div style="padding: 20px; color: red;">Error loading app. Check console.</div>'
  }
}
