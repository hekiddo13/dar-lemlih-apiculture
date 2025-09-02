import { AlertCircle } from 'lucide-react';
import { cn } from '../../lib/utils';

interface ErrorProps {
  message: string;
  className?: string;
  retry?: () => void;
}

export default function Error({ message, className, retry }: ErrorProps) {
  return (
    <div
      className={cn(
        'flex flex-col items-center justify-center p-8 text-center',
        className
      )}
    >
      <AlertCircle className="h-12 w-12 text-red-500 mb-4" />
      <p className="text-gray-700 mb-4">{message}</p>
      {retry && (
        <button
          onClick={retry}
          className="px-4 py-2 bg-orange-500 text-white rounded-lg hover:bg-orange-600 transition-colors"
        >
          Try Again
        </button>
      )}
    </div>
  );
}
