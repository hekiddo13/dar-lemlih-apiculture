import { useTranslation } from 'react-i18next';
import { Check } from 'lucide-react';

interface CheckoutStepsProps {
  currentStep: number;
}

export default function CheckoutSteps({ currentStep }: CheckoutStepsProps) {
  const { t } = useTranslation();
  
  const steps = [
    { id: 1, name: t('checkout.step1') },
    { id: 2, name: t('checkout.step2') },
    { id: 3, name: t('checkout.step3') },
  ];

  return (
    <div className="flex items-center justify-center mb-8">
      {steps.map((step, index) => (
        <div key={step.id} className="flex items-center">
          <div
            className={`
              w-10 h-10 rounded-full flex items-center justify-center
              ${currentStep > step.id ? 'bg-green-500 text-white' : 
                currentStep === step.id ? 'bg-honey text-white' : 
                'bg-gray-200 text-gray-600'}
            `}
          >
            {currentStep > step.id ? <Check size={20} /> : step.id}
          </div>
          <span className="ml-2 text-sm font-medium">{step.name}</span>
          {index < steps.length - 1 && (
            <div className={`w-20 h-1 mx-4 ${currentStep > step.id ? 'bg-green-500' : 'bg-gray-200'}`} />
          )}
        </div>
      ))}
    </div>
  );
}
