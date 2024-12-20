import * as React from 'react';
import { DateTime } from 'luxon';
import { Calendar as CalendarIcon } from 'lucide-react';

import { Button } from '@/components/ui/button';
import { Calendar } from '@/components/ui/calendar';
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover';
import { cn } from '@/lib/utils';
import { SelectSingleEventHandler } from 'react-day-picker';
import { Label } from '@/components/ui/label';
import { Input } from '@/components/ui/input';

interface DateTimePickerProps {
  date: Date;
  setDate: (date: Date) => void;
}

export function DateTimePicker({ date, setDate }: DateTimePickerProps) {
  const [selectedDateTime, setSelectedDateTime] = React.useState<DateTime>(
    DateTime.fromJSDate(date)
  );

  // Handle date selection
  const handleSelect: SelectSingleEventHandler = (day) => {
    if (!day) return;
    
    const newDateTime = DateTime.fromJSDate(day).set({
      hour: selectedDateTime.hour || 0,
      minute: selectedDateTime.minute || 0
    });

    setSelectedDateTime(newDateTime);
    setDate(newDateTime.toJSDate());
  };

  // Handle time input changes
  const handleTimeChange: React.ChangeEventHandler<HTMLInputElement> = (e) => {
    const { value } = e.target;
    const [hours, minutes] = value.split(':').map(num => parseInt(num, 10));
    
    if (isNaN(hours) || isNaN(minutes)) return;

    const newDateTime = selectedDateTime.set({
      hour: hours,
      minute: minutes
    });

    setSelectedDateTime(newDateTime);
    setDate(newDateTime.toJSDate());
  };

  const footer = (
    <>
      <div className="px-4 pt-0 pb-4">
        <Label>Time</Label>
        <Input
          type="time"
          onChange={handleTimeChange}
          value={selectedDateTime.toFormat('HH:mm')}
        />
      </div>
      {!selectedDateTime && <p>Please pick a day.</p>}
    </>
  );

  return (
    <Popover>
      <PopoverTrigger asChild>
        <Button
          variant="outline"
          className={cn(
            'h-10 w-full py-6 font-[family-name:var(--font-geist-sans)] border-none hover:bg-neutral-50 text-md bg-neutral-50 shadow-none text-neutral-500 font-medium rounded-[10px] justify-start text-left font-normal',
            !date && 'text-muted-foreground'
          )}
        >
          <CalendarIcon className="mr-2 h-4 w-4" />
          {date ? (
            selectedDateTime.setLocale('fr').toFormat('dd LLLL yyyy HH:mm')
          ) : (
            <span>Pick a date</span>
          )}
        </Button>
      </PopoverTrigger>
      <PopoverContent className="w-auto p-0">
        <Calendar
          mode="single"
          selected={selectedDateTime.toJSDate()}
          onSelect={handleSelect}
          initialFocus
        />
        {footer}
      </PopoverContent>
    </Popover>
  );
}