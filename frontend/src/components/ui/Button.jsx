export default function Button({ className = '', children, ...props }) {
  const btnBase = [
    'rounded-xl',
    'border-2',
    'px-6', 'py-3',
    'text-lg', 'font-semibold',
    'shadow-[0_4px_0_#2B3541]',
    'transition-all',
    'active:shadow-[0_2px_0_#2B3541]',
    'active:translate-y-1',
    'cursor-pointer'
  ].join(' ')

  return (
    <button
      className={`${btnBase} ${className}`}
      {...props}
    >
      {children}
    </button>
  )
}