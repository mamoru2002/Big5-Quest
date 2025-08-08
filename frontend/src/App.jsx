import React from 'react'
import { BrowserRouter, Routes, Route } from 'react-router-dom'
import DiagnosisForm from './pages/DiagnosisForm'
import ResultPage from './pages/ResultPage'

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<DiagnosisForm />} />
        <Route path="/result/:id" element={<ResultPage />} />
      </Routes>
    </BrowserRouter>
  )
}