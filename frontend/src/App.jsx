import { Routes, Route } from 'react-router-dom'
import DiagnosisForm from './pages/DiagnosisForm'
import ResultPage from './pages/ResultPage'
import ChallengeSelection from './pages/ChallengeSelection'
import Dashboard from './pages/Dashboard'

export default function App() {
  return (
    <Routes>
      <Route path="/" element={<DiagnosisForm />} />
      <Route path="/result/:id" element={<ResultPage />} />
      <Route path="/select/:id/:code" element={<ChallengeSelection />} />
      <Route path="/dashboard" element={<Dashboard />} />
    </Routes>
  )
}