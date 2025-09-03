import { Routes, Route } from 'react-router-dom';

export default function SimpleApp() {
  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white shadow-sm p-4">
        <h1 className="text-xl font-bold">Dar Lemlih - Simple Version</h1>
      </header>
      <main className="p-4">
        <Routes>
          <Route path="/" element={
            <div>
              <h2 className="text-2xl mb-4">Welcome!</h2>
              <p>The app is loading. This is a simplified version.</p>
              <p className="mt-4">If you see this, React Router is working.</p>
            </div>
          } />
          <Route path="*" element={<div>Page not found</div>} />
        </Routes>
      </main>
    </div>
  );
}
