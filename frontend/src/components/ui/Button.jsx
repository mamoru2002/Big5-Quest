export default function Button({ className = '', children, ...props }) {
  const base = [
    'inline-flex items-center justify-center select-none',
    'rounded-xl border-2 border-[#2B3541]',
    'px-6 py-3 text-lg',
    'shadow-[0_5px_0_#2B3541]',
    'transition-all duration-150',
    'active:translate-y-[5px] active:shadow-none',
    'cursor-pointer disabled:cursor-not-allowed disabled:opacity-50',
  ].join(' ')

  return (
    <button className={`${base} ${className}`} {...props}>
      {children}
    </button>
  )
}