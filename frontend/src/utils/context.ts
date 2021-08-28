import React, { ReactNode } from 'react';
import { UserModel } from '../models/user';

export interface AlertClass {
    id: string;
    contents: ReactNode;
    variant: string;
    timeout: number;
    __timeout?: NodeJS.Timeout;
}

export interface AppContextClass {
    user?: UserModel;
    userLoaded: boolean;
    showAlert(alert: AlertClass): void;
    closeAlert(id: string): void;
    refreshUser(): Promise<void>;
}

export const AppContext = React.createContext<AppContextClass>(
    {} as AppContextClass,
);