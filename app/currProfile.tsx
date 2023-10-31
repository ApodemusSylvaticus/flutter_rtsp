import React, { useEffect, useMemo, useState } from 'react';
import { useTheme } from 'styled-components/native';
import { useTranslation } from 'react-i18next';
import { AppContainer } from '@/components/container/appContainer';
import { DefaultColumnContainer } from '@/components/container/defaultBox';
import { useActiveProfileStore } from '@/store/useActiveProfileStore';
import { ProfileWorker } from '@/core/profileWorker';
import { Text20 } from '@/components/text/styled';
import { Profile } from '@/components/profile';
import { WithFileName } from '@/interface/helper';
import { IBullet, ICartridge, IDescription, IRiffle, IZeroing } from '@/interface/profile';
import { DefaultButton } from '@/components/button/style';
import { Loader } from '@/components/loader';
import { NotificationEnum, useNotificationStore } from '@/store/useNotificationStore';
import { useProfileStore } from '@/store/useProfileStore';
import { IDraggableListItem } from '@/store/useModalControllerStore';
import { DraggableDistanceListModalMemo } from '@/components/modals/draggebleDistanceList';
import { useA } from '@/hooks/useGetVelocityParam';
import { DeleteButtonWithConfirm } from '@/components/button/deleteButtonWithConfirm';
import { RetryWithErrorMsg } from '@/components/retry';

const Content: React.FC = () => {
    const sendNotification = useNotificationStore(state => state.sendNotification);
    const importProfile = useProfileStore(state => state.importProfile);
    const [isLoading, setIsLoading] = useState(true);
    const [errorMsg, setErrorMsg] = useState('');
    const [shouldRetry, setShouldRetry] = useState(false);
    const { activeProfilesMap, activeProfile, setProfile, deleteProfile } = useActiveProfileStore(state => ({
        activeProfilesMap: state.activeProfilesMap,
        activeProfile: state.activeProfile,
        setProfile: state.setProfile,
        deleteProfile: state.deleteProfile,
    }));

    const { t } = useTranslation();

    const profileWorker = useMemo(() => new ProfileWorker(), []);

    const { rem } = useTheme();

    const val = activeProfilesMap[activeProfile];

    const retryHandler = () => {
        setShouldRetry(true);
    };

    useEffect(() => {
        if (activeProfile === '' || activeProfilesMap[activeProfile] !== null) {
            setIsLoading(false);
            return;
        }

        setIsLoading(true);
        setErrorMsg('');
        profileWorker
            .getProfile(activeProfile)
            .then(value => setProfile(activeProfile, value))
            .catch(() => setErrorMsg(t('error_failed_to_get_profile_data')))
            .finally(() => setIsLoading(false));
    }, [activeProfilesMap, activeProfile, profileWorker, setProfile]);

    useEffect(() => {
        if (!shouldRetry) {
            return;
        }
        setShouldRetry(false);
        setIsLoading(true);
        setErrorMsg('');
        profileWorker
            .getProfile(activeProfile)
            .then(value => setProfile(activeProfile, value))
            .catch(() => setErrorMsg(t('error_failed_to_get_profile_data')))
            .finally(() => setIsLoading(false));
    }, [activeProfilesMap, activeProfile, profileWorker, setProfile, shouldRetry, t]);

    const handleChange = (
        data:
            | WithFileName<IZeroing>
            | WithFileName<IBullet>
            | WithFileName<ICartridge>
            | WithFileName<IRiffle>
            | WithFileName<IDescription>,
    ) => {
        const {
            switches,
            profileName,
            rTwist,
            twistDir,
            caliber,
            coefG1,
            coefG7,
            bcType,
            bLength,
            bWeight,
            zeroX,
            zeroY,
            cZeroPTemperature,
            cZeroAirTemperature,
            cZeroAirHumidity,
            cZeroAirPressure,
            cZeroWPitch,
            cZeroDistanceIdx,
            distances,
            cZeroTemperature,
            cTCoeff,
            cMuzzleVelocity,
            deviceUuid,
            bulletName,
            shortNameTop,
            cartridgeName,
            shortNameBot,
            userNote,
            bDiameter,
            scHeight,
            fileName,
        } = activeProfilesMap[activeProfile]!;

        profileWorker
            .saveChanges(activeProfile, {
                deviceUuid,
                fileName: data.fileName ?? fileName,
                profileName: data.profileName ?? profileName,
                userNote: data.userNote ?? userNote,
                cTCoeff: data.cTCoeff ?? cTCoeff,
                cMuzzleVelocity: data.cMuzzleVelocity ?? cMuzzleVelocity,
                cZeroTemperature: data.cZeroTemperature ?? cZeroTemperature,
                zeroY: data.zeroY ?? zeroY,
                cZeroPTemperature: data.cZeroPTemperature ?? cZeroPTemperature,
                cZeroAirTemperature: data.cZeroAirTemperature ?? cZeroAirTemperature,
                cZeroAirHumidity: data.cZeroAirHumidity ?? cZeroAirHumidity,
                cZeroAirPressure: data.cZeroAirPressure ?? cZeroAirPressure,
                cZeroWPitch: data.cZeroWPitch ?? cZeroWPitch,
                cZeroDistanceIdx: data.cZeroDistanceIdx ?? cZeroDistanceIdx,
                distances: data.distances ?? distances,
                twistDir: data.twistDir ?? twistDir,
                rTwist: data.rTwist ?? rTwist,
                bulletName: data.bulletName ?? bulletName,
                shortNameTop: data.shortNameTop ?? shortNameTop,
                cartridgeName: data.cartridgeName ?? cartridgeName,
                shortNameBot: data.shortNameBot ?? shortNameBot,
                bLength: data.bLength ?? bLength,
                bWeight: data.bWeight ?? bWeight,
                zeroX: data.zeroX ?? zeroX,
                bDiameter: data.bDiameter ?? bDiameter,
                switches: data.switches ?? switches,
                scHeight: data.scHeight ?? scHeight,
                bcType: data.bcType ?? bcType,
                caliber: data.caliber ?? caliber,
                coefRows: (data.bcType ?? bcType) === 'G1' ? data.coefG1 ?? coefG1 : data.coefG7 ?? coefG7,
            })
            .then(res => {
                if (res.ok) {
                    profileWorker.getProfile(activeProfile).then(value => {
                        sendNotification({ type: NotificationEnum.SUCCESS, msg: t('default_profile_updated') });
                        setProfile(activeProfile, value);
                    });
                } else {
                    console.log(res);
                    sendNotification({ type: NotificationEnum.SUCCESS, msg: t('error_failed_to_update_profile_data') });
                }
            });
    };

    const exportProfileHandler = () => {
        if (val) {
            importProfile(val);
            sendNotification({ msg: t('default_profile_added'), type: NotificationEnum.SUCCESS });
        }
    };

    const handleAccept = () => {
        profileWorker
            .deleteFileButton(activeProfile)
            .then(() => {
                sendNotification({ msg: t('default_profile_deleted'), type: NotificationEnum.SUCCESS });
                deleteProfile(activeProfile);
            })
            .catch(e => {
                console.log(e);
                sendNotification({ msg: t('default_failed_to_delete_profile'), type: NotificationEnum.ERROR });
            });
    };

    const handleRefreshList = () => {
        profileWorker
            .serveRefreshList()
            .then(() => {
                sendNotification({ msg: t('default_list_refreshed'), type: NotificationEnum.SUCCESS });
                deleteProfile(activeProfile);
            })
            .catch(e => {
                console.log(e);
                sendNotification({ msg: t('error_failed_ref_list'), type: NotificationEnum.ERROR });
            });
    };

    const handleChangeDistances = (data: IDraggableListItem[]) => {
        const list: number[] = [];
        let zeroIdx: number = 0;
        data.forEach((el, index) => {
            if (el.isZeroDistance) {
                zeroIdx = index;
            }
            list.push(+el.title);
        });

        const {
            switches,
            profileName,
            rTwist,
            twistDir,
            caliber,
            coefG1,
            coefG7,
            bcType,
            bLength,
            bWeight,
            zeroX,
            zeroY,
            cZeroPTemperature,
            cZeroAirTemperature,
            cZeroAirHumidity,
            cZeroAirPressure,
            cZeroWPitch,
            cZeroTemperature,
            cTCoeff,
            cMuzzleVelocity,
            deviceUuid,
            bulletName,
            shortNameTop,
            cartridgeName,
            shortNameBot,
            userNote,
            bDiameter,
            scHeight,
            fileName,
        } = activeProfilesMap[activeProfile]!;

        profileWorker
            .saveChanges(activeProfile, {
                deviceUuid,
                fileName,
                profileName,
                userNote,
                cTCoeff,
                cMuzzleVelocity,
                cZeroTemperature,
                zeroY,
                cZeroPTemperature,
                cZeroAirTemperature,
                cZeroAirHumidity,
                cZeroAirPressure,
                cZeroWPitch,
                cZeroDistanceIdx: zeroIdx,
                distances: list,
                twistDir,
                rTwist,
                bulletName,
                shortNameTop,
                cartridgeName,
                shortNameBot,
                bLength,
                bWeight,
                zeroX,
                bDiameter,
                switches,
                scHeight,
                bcType,
                caliber,
                coefRows: bcType === 'G1' ? coefG1 : coefG7,
            })
            .then(res => {
                if (res.ok) {
                    profileWorker.getProfile(activeProfile).then(value => {
                        sendNotification({ type: NotificationEnum.SUCCESS, msg: t('default_profile_updated') });
                        setProfile(activeProfile, value);
                    });
                } else {
                    console.log(res);
                    sendNotification({ type: NotificationEnum.SUCCESS, msg: t('error_failed_to_update_profile_data') });
                }
            });
    };

    if (isLoading) {
        return <Loader size={rem * 3.2} />;
    }

    if (errorMsg) {
        return <RetryWithErrorMsg retryHandler={retryHandler} msg={errorMsg} />;
    }

    if (val === null) {
        // eslint-disable-next-line consistent-return
        return;
    }

    return (
        <DefaultColumnContainer>
            <Profile
                {...val}
                isFileNameChangeable={false}
                setBullet={handleChange}
                setCartridge={handleChange}
                setDescription={handleChange}
                setRiffle={handleChange}
                setZeroing={handleChange}
                setDistances={handleChangeDistances}
            />

            <DefaultButton onPress={exportProfileHandler}>
                <Text20>{t('profile_export_this_to_all')}</Text20>
            </DefaultButton>

            <DefaultButton onPress={handleRefreshList}>
                <Text20>Server: refresh list</Text20>
            </DefaultButton>

            <DeleteButtonWithConfirm
                confirmMsg={t('profile_are_you_sure_delete')}
                buttonText={t('profile_delete_profile')}
                confirmHandler={handleAccept}
            />

            <DraggableDistanceListModalMemo />
        </DefaultColumnContainer>
    );
};

export const CurrProfile: React.FC = () => {
    const { rem } = useTheme();

    const { isLoading, errorMsg, retryHandler } = useA();

    return (
        <AppContainer>
            {isLoading && <Loader size={rem * 3.2} />}
            {!isLoading && errorMsg !== '' && <RetryWithErrorMsg retryHandler={retryHandler} msg={errorMsg} />}
            {!isLoading && errorMsg === '' && <Content />}
        </AppContainer>
    );
};

export default CurrProfile;
