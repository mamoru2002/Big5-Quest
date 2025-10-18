import React from 'react';

export default function ToggleSwitch({
  checked,
  onChange,
  disabled = false,
  labelLeft,
  labelRight,
}) {
  return (
    <div className="flex items-center gap-3">
      {labelLeft && <span className="text-[16px]">{labelLeft}</span>}

      <button
        type="button"
        role="switch"
        aria-checked={checked}
        aria-label="toggle"
        disabled={disabled}
        onClick={() => {
          if (disabled) return;
          onChange && onChange(!checked);
        }}
        className={[
          'relative w-14 h-7 rounded-full border-[1.5px] border-[#2B3541] transition-colors',
          checked ? 'bg-[#00A8A5]' : 'bg-gray-200',
          disabled ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer',
        ].join(' ')}
      >
        <span
          className={[
            'absolute top-1/2 -translate-y-1/2 w-6 h-6 rounded-full bg-white transition-[left,right]',
          ].join(' ')}
          style={checked ? { right: 2 } : { left: 2 }}
        />
      </button>

      {labelRight && <span className="text-[16px]">{labelRight}</span>}
    </div>
  );
}