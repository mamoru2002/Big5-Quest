import React from 'react';
import { Outlet } from 'react-router-dom';
import TopBar from '../components/TopBar';

export default function AppShell() {
  return (
    <>
      <TopBar />

      <main className="lg:ml-72">
        <Outlet />
      </main>
    </>
  );
}