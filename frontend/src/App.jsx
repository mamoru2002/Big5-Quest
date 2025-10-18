// frontend/src/App.jsx
import { Routes, Route, Navigate } from 'react-router-dom';
import AppShell from './layouts/AppShell';

import Welcome from './pages/Welcome';
import DiagnosisForm from './pages/DiagnosisForm';
import ResultPage from './pages/ResultPage';
import ChallengeSelection from './pages/ChallengeSelection';
import Dashboard from './pages/Dashboard';

import SignIn from './pages/auth/SignIn';
import SignUp from './pages/auth/SignUp';
import VerifyNotice from './pages/auth/VerifyNotice';
import Logout from './pages/auth/Logout';

import ProtectedRoute from './components/ProtectedRoute';

export default function App() {
  return (
    <Routes>
      <Route element={<AppShell />}>
        <Route index element={<Welcome />} />
        <Route path="signin" element={<SignIn />} />
        <Route path="signup" element={<SignUp />} />
        <Route path="verify" element={<VerifyNotice />} />

        <Route element={<ProtectedRoute />}>
          <Route path="diagnosis" element={<DiagnosisForm />} />
          <Route path="result/:id" element={<ResultPage />} />
          <Route path="select/:id/:code" element={<ChallengeSelection />} />
          <Route path="dashboard" element={<Dashboard />} />
        </Route>

        <Route path="logout" element={<Logout />} />
      </Route>

      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}