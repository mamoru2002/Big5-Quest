import { Routes, Route, Navigate } from 'react-router-dom'
import AppShell from './layouts/AppShell'

import Welcome from './pages/Welcome'
import DiagnosisForm from './pages/DiagnosisForm'
import ResultPage from './pages/ResultPage'
import ChallengeSelection from './pages/ChallengeSelection'
import Dashboard from './pages/Dashboard'
import MyPage from './pages/MyPage'
import Rest from './pages/Rest'

import SignIn from './pages/auth/SignIn'
import SignUp from './pages/auth/SignUp'
import VerifyNotice from './pages/auth/VerifyNotice'
import ForgotPassword from './pages/auth/ForgotPassword'
import ResetPassword from './pages/auth/ResetPassword'
import Logout from './pages/auth/Logout'
import ProtectedRoute from './components/ProtectedRoute'

export default function App() {
  return (
    <Routes>
      <Route element={<AppShell />}>
        <Route path="/" element={<Welcome />} />
        <Route path="/signin" element={<SignIn />} />
        <Route path="/signup" element={<SignUp />} />
        <Route path="/verify" element={<VerifyNotice />} />
        <Route path="/forgot" element={<ForgotPassword />} />
        <Route path="/reset" element={<ResetPassword />} />

        <Route element={<ProtectedRoute />}>
          <Route path="/diagnosis" element={<DiagnosisForm />} />
          <Route path="/result/:id" element={<ResultPage />} />
          <Route path="/select/:id/:code" element={<ChallengeSelection />} />
          <Route path="/dashboard" element={<Dashboard />} />
          <Route path="/rest" element={<Rest />} />
          <Route path="/mypage" element={<MyPage />} />
        </Route>

        <Route path="/logout" element={<Logout />} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Route>
    </Routes>
  )
}