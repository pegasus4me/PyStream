'use client'
import { useMediaQuery } from 'usehooks-ts'
import React, { type ReactNode } from 'react'

export default function ScreenManager({ children }: { children: ReactNode }): JSX.Element {
    const matches = useMediaQuery('(min-width: 868px)')
    console.log('mat', matches)
    return (
        <div className={`${matches ? 'block' : 'hidden'}`}>
            
            {children}
        </div>
    )
}