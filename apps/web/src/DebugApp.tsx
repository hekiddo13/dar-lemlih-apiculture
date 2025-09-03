import { useState } from 'react';

export default function DebugApp() {
  const [status, setStatus] = useState<string[]>(['App starting...']);
  
  const addStatus = (msg: string) => {
    setStatus(prev => [...prev, msg]);
  };

  // Test various imports
  const testImports = async () => {
    try {
      addStatus('Testing React Router...');
      const { Routes, Route } = await import('react-router-dom');
      addStatus('✓ React Router loaded');
    } catch (e: any) {
      addStatus(`✗ React Router failed: ${e.message}`);
    }

    try {
      addStatus('Testing i18n...');
      await import('./i18n');
      addStatus('✓ i18n loaded');
    } catch (e: any) {
      addStatus(`✗ i18n failed: ${e.message}`);
    }

    try {
      addStatus('Testing HomePage...');
      await import('./pages/HomePage');
      addStatus('✓ HomePage loaded');
    } catch (e: any) {
      addStatus(`✗ HomePage failed: ${e.message}`);
    }

    try {
      addStatus('Testing auth store...');
      await import('./stores/authStore');
      addStatus('✓ Auth store loaded');
    } catch (e: any) {
      addStatus(`✗ Auth store failed: ${e.message}`);
    }
  };

  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold mb-4">Debug App</h1>
      <button 
        onClick={testImports}
        className="bg-blue-500 text-white px-4 py-2 rounded mb-4"
      >
        Test Imports
      </button>
      <div className="space-y-1">
        {status.map((msg, i) => (
          <div key={i} className={msg.includes('✗') ? 'text-red-600' : msg.includes('✓') ? 'text-green-600' : ''}>
            {msg}
          </div>
        ))}
      </div>
    </div>
  );
}
