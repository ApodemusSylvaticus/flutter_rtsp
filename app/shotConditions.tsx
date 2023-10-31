import React, { useEffect, useMemo, useState } from 'react';
import { useTheme } from 'styled-components/native';
import { useTranslation } from 'react-i18next';
import { AppContainer } from '@/components/container/appContainer';
import { EnvironmentParam, WindParamColumn } from '@/components/envParamCard';
import { DefaultColumnContainer } from '@/components/container/defaultBox';
import { CoreProtobuf } from '@/core/coreProtobuf';
import { useDevStatusStore } from '@/store/useDevStatusStore';
import { useSettingStore } from '@/store/useSettingStore';
import { Loader } from '@/components/loader';
import { RetryWithErrorMsg } from '@/components/retry';

const ShotConditions: React.FC = () => {
    const { setDevStatus, setActiveProfile, devStatus } = useDevStatusStore(state => ({
        setDevStatus: state.setDevStatus,
        setActiveProfile: state.setActiveProfile,
        devStatus: state.devStatus,
    }));
    const { t } = useTranslation();
    const { rem } = useTheme();
    const [shouldRetry, setShouldRetry] = useState(false);

    const [isLoading, setIsLoading] = useState(!devStatus);
    const [errorMsg, setErrorMsg] = useState('');

    const serverApi = useSettingStore(state => state.serverHost);

    const coreProtobuf = useMemo(() => {
        const protobuf = new CoreProtobuf();
        protobuf.setSetterParam({ setDevStatus, setActiveProfile, setIsLoading, setErrorMsg, t });
        return protobuf;
    }, []);

    useEffect(() => {
        coreProtobuf.connect(serverApi);
    }, [serverApi]);

    useEffect(() => {
        if (shouldRetry) {
            coreProtobuf.connect(serverApi);
            setShouldRetry(false);
        }
    }, [serverApi, shouldRetry]);

    return (
        <AppContainer>
            {isLoading && <Loader size={rem * 3.2} />}
            {!isLoading && errorMsg !== '' && (
                <RetryWithErrorMsg retryHandler={() => setShouldRetry(true)} msg={errorMsg} />
            )}

            {!isLoading && errorMsg === '' && (
                <DefaultColumnContainer>
                    <WindParamColumn />
                    <EnvironmentParam />
                </DefaultColumnContainer>
            )}
        </AppContainer>
    );
};

export default ShotConditions;
