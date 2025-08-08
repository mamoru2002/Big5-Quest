import React from 'react';

export default function Layout({ children, className = '' }) {
  return (
    <div className={`w-full max-w-[420px] mx-auto mb-4 px-4 ${className}`}>
      {children}
    </div>
  );
}