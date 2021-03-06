import React, { useContext } from 'react';
import { formatSize, formatSizeWithInfinite } from '../utils/formatting';

import { AppContext } from '../utils/context';
import ProgressBar from 'react-bootstrap/ProgressBar';

const ProgressBarLabel: React.FC<{ isChild?: boolean }> = ({ children }) => {
    return <div className="justify-content-center d-flex position-absolute w-100">{children}</div>;
};

export const StorageUseBar: React.FC = () => {
    const { user } = useContext(AppContext);
    if (!user) {
        return null;
    }

    const nowPerc = user.storage_quota < 0 ? 0 : Math.round((user.storage_used / user.storage_quota) * 100);

    return (
        <ProgressBar className="position-relative">
            <ProgressBar now={nowPerc} />
            <ProgressBarLabel>{`${formatSize(user.storage_used)} / ${formatSizeWithInfinite(
                user.storage_quota,
            )}`}</ProgressBarLabel>
        </ProgressBar>
    );
};
