import React from 'react'
import { Routes, Route } from 'react-router-dom'
import DiagnosisForm from './components/DiagnosisForm'
import ResultPage     from './components/ResultPage'

export default function App() {
  return (
    <Routes>
      <Route path="/" element={<DiagnosisForm />} />
      <Route path="/result/:id" element={<ResultPage />} />
    </Routes>
  )
}