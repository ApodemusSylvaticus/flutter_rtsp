import { ActiveProfileMap } from '@/store/useActiveProfileStore';
import { IProfileListServerData } from '@/interface/core/profileProtobuf';
import { DevStatus } from '@/store/useDevStatusStore';
import { ZOOM } from '@/interface/core/coreProtobuf';
import { ReticlesFolders } from '@/store/useReticlesStore';

interface TestActiveProfile {
    activeProfilesMap: ActiveProfileMap;
    activeProfile: string;
    fileList: string[];
    profileListServerData: IProfileListServerData;
    isTesting: boolean;
}

export const testActiveProfile: TestActiveProfile = {
    isTesting: true,
    activeProfile: 'first.a7p',
    activeProfilesMap: {
        'first.a7p': {
            deviceUuid: 'abc123',
            switches: [
                {
                    cIdx: 1,
                    distance: 100,
                    distanceFrom: 'muzzle',
                    reticleIdx: 3,
                    zoom: 4,
                },
                {
                    cIdx: 2,
                    distance: 200,
                    distanceFrom: 'muzzle',
                    reticleIdx: 5,
                    zoom: 6,
                },
            ],
            caliber: '6.5mm',
            scHeight: 2.5,
            rTwist: 1.8,
            twistDir: 'RIGHT',
            cMuzzleVelocity: 3000,
            cZeroTemperature: 25,
            cTCoeff: 0.2,
            profileName: 'Long Range Shooter',
            cartridgeName: 'Hornady 6.5mm',
            bulletName: 'ELD Match',
            shortNameTop: 'LRS',
            shortNameBot: 'H65',
            fileName: 'first.a7p',
            userNote: 'Customized for extreme long-range accuracy.',
            bDiameter: 0.264,
            bWeight: 140,
            bLength: 1.2,
            coefG1: [{ bcCd: 0.345, mv: 2800 }],
            coefG7: [{ bcCd: 0.345, mv: 2800 }],
            coefCustom: [{ bcCd: 0.345, mv: 2800 }],
            bcType: 'G1',
            zeroX: 0,
            zeroY: 0,
            cZeroDistanceIdx: 3,
            cZeroAirTemperature: 20,
            cZeroAirPressure: 1013,
            cZeroAirHumidity: 50,
            cZeroWPitch: 0,
            cZeroPTemperature: 25,
            distances: [100, 200, 300, 400, 500],
        },
        'second.a7p': {
            deviceUuid: 'xyz789',
            switches: [
                {
                    cIdx: 1,
                    distance: 50,
                    distanceFrom: 'muzzle',
                    reticleIdx: 2,
                    zoom: 3,
                },
                {
                    cIdx: 2,
                    distance: 100,
                    distanceFrom: 'muzzle',
                    reticleIdx: 4,
                    zoom: 5,
                },
            ],
            caliber: '308 Win',
            scHeight: 2.8,
            rTwist: 1.1,
            twistDir: 'LEFT',
            cMuzzleVelocity: 2800,
            cZeroTemperature: 22,
            cTCoeff: 0.18,
            profileName: 'Mid-Range Hunter',
            cartridgeName: 'Federal 308 Win',
            bulletName: 'Nosler AccuBond',
            shortNameTop: 'MRH',
            shortNameBot: 'F308',
            fileName: 'second.a7p',
            userNote: 'Optimized for precise shots at moderate distances.',
            bDiameter: 0.308,
            bWeight: 165,
            bLength: 1.4,
            coefG1: [{ bcCd: 0.4, mv: 3200 }],
            coefG7: [{ bcCd: 0.4, mv: 3200 }],
            coefCustom: [{ bcCd: 0.4, mv: 3200 }],
            bcType: 'G1',
            zeroX: 0,
            zeroY: 0,
            cZeroDistanceIdx: 2,
            cZeroAirTemperature: 18,
            cZeroAirPressure: 1015,
            cZeroAirHumidity: 45,
            cZeroWPitch: 0,
            cZeroPTemperature: 22,
            distances: [50, 100, 150, 200, 250],
        },
        'third.a7p': {
            deviceUuid: 'asdxzc',
            switches: [
                {
                    cIdx: 1,
                    distance: 50,
                    distanceFrom: 'muzzle',
                    reticleIdx: 2,
                    zoom: 3,
                },
                {
                    cIdx: 2,
                    distance: 100,
                    distanceFrom: 'muzzle',
                    reticleIdx: 4,
                    zoom: 5,
                },
            ],
            caliber: '3082 Win',
            scHeight: 2.8,
            rTwist: 1.1,
            twistDir: 'LEFT',
            cMuzzleVelocity: 2800,
            cZeroTemperature: 22,
            cTCoeff: 0.18,
            profileName: 'TestPr',
            cartridgeName: 'Federal 308 Win',
            bulletName: 'Nosler AccuBond',
            shortNameTop: 'asdaszx',
            shortNameBot: 'F3asd08',
            fileName: 'third.a7p',
            userNote: 'Optimized for precise shots at moderate distances.',
            bDiameter: 0.308,
            bWeight: 165,
            bLength: 1.4,
            coefG1: [{ bcCd: 0.4, mv: 3200 }],
            coefG7: [{ bcCd: 0.4, mv: 3200 }],
            coefCustom: [{ bcCd: 0.4, mv: 3200 }],
            bcType: 'G1',
            zeroX: 0,
            zeroY: 0,
            cZeroDistanceIdx: 2,
            cZeroAirTemperature: 18,
            cZeroAirPressure: 1015,
            cZeroAirHumidity: 45,
            cZeroWPitch: 0,
            cZeroPTemperature: 22,
            distances: [50, 100, 150, 200, 250],
        },
    },
    fileList: ['first.a7p', 'second.a7p', 'third.a7p'],
    profileListServerData: {
        activeprofile: 0,
        profileDesc: [
            {
                shortNameTop: 'LRS',
                shortNameBot: 'H65',
                profileName: 'Long Range Shooter',
                cartridgeName: 'Hornady 6.5mm',
                filePath: 'first.a7p',
            },
            {
                profileName: 'Mid-Range Hunter',
                cartridgeName: 'Federal 308 Win',
                shortNameTop: 'MRH',
                shortNameBot: 'F308',
                filePath: 'second.a7p',
            },
            {
                profileName: 'Test',
                cartridgeName: 'Federal 308 Win',
                shortNameTop: 'dsfs',
                shortNameBot: 'sdfsdfsdf',
                filePath: 'third.a7p',
            },
        ],
    },
};

interface TestShotConditional {
    isTesting: boolean;
    devStatus: DevStatus;
    activeProfile: string;
}
export const testShotConditional: TestShotConditional = {
    isTesting: true,
    devStatus: {
        airPress: 200,
        distance: 300,
        windDir: 30,
        powderTemp: 2,
        charge: 2,
        currProfile: 1,
        airTemp: 2,
        airHum: 3,
        zoom: ZOOM.X1,
        pitch: 0,
        cant: 0,
    },
    activeProfile: 'first.a7p',
};

interface TestReticles {
    reticlesFolders: ReticlesFolders;
    isTesting: boolean;
}

export const testReticles: TestReticles = {
    isTesting: true,
    reticlesFolders: {
        folderList: ['r', 'test'],
        folders: {
            r: [
                {
                    fileName: 0,
                    base64Str:
                },
            ],
            test: [
                {
                    fileName: 0,
                    base64Str:
                        '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',
                },
                {
                    fileName: 1,
                    base64Str:
                        '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',
                },
                {
                    fileName: 2,
                    base64Str:
                        'iVBORw0KGgoAAAANSUhEUgAAAoAAAAHgCAYAAAA10dzkAAAABHNCSVQICAgIfAhkiAAADZZJREFUeJzt3eFum0oCgNHlqu//yuyPla+8mNQQYxvmO0eqlDjEdUjafp2BmWme5/k/AABk/PPtFwAAwGcJQACAGAEIABAjAAEAYgQgAECMAAQAiBGAAAAxAhAAIEYAAgDECEAAgBgBCAAQIwABAGIEIABAjAAEAIgRgAAAMQIQACBGAAIAxAhAAIAYAQgAECMAAQBiBCAAQIwABACIEYAAADECEAAgRgACAMQIQACAGAEIABAjAAEAYgQgAECMAAQAiBGAAAAxAhAAIEYAAgDECEAAgBgBCAAQIwABAGIEIABAjAAEAIgRgAAAMQIQACBGAAIAxAhAAIAYAQgAECMAAQBiBCAAQIwABACIEYAAADECEAAgRgACAMQIQACAGAEIABAjAAEAYgQgAECMAAQAiBGAAAAxAhAAIEYAAgDECEAAgBgBCAAQIwABAGIEIABAjAAEAIgRgAAAMQIQACBGAAIAxPz59gsomqbp37fnef7iKwEAiowAAgDECEAAgBhTwF9g2hcA+CYjgAAAMQIQACBGAAIAxAhAAIAYAQgAECMAAQBiBCAAQIwABACIsRD0idgjGAD4BCOAAAAxAhAAIMYU8ImY9gUAPsEIIABAjAAEAIgRgAAAMQIQACBGAAIAxLgLeFD3i0rfLO8ynqZp02N7Pn7E6wIA3mua/es7tFeD7d3O/voAYESmgAd1G2m7xdXayNvWx/Z8fOvruhF/APB5RgAHd7YRNlPAAPB9RgAHddYRwNtruv8FAHyWABzUMvzWQmvrY3s+vscRMQkA7Ocu4EHdpn7vQ3DrXcBL98e8+vHl42ebogaAAtcAAgDEmAIGAIgRgAAAMQIQACBGAAIAxAhAAIAYAQgAECMAAQBiBCAAQIwABACIEYAAADECEAAgRgACAMQIQACAGAEIABAjAAEAYgQgAECMAAQAiBGAAAAxAhAAIEYAAgDECEAAgBgBCAAQIwABAGIEIABAjAAEAIgRgAAAMQIQACBGAAIAxAhAAIAYAQgAECMAAQBiBCAAQIwABACIEYAAADECEAAgRgACAMQIQACAGAEIABAjAAEAYgQgAECMAAQAiBGAAAAxAhAAIEYAAgDECEAAgJg/334BAEebpunw55zn+fDnBPgWAQgMZ2usTdMk7IAkU8AAADECEAAgRgACAMQIQACAGAEIABAjAAEAYgQgAECMAAQAiLEQNJCxtkPI8jELQwMFAhDIWMadnUCAKlPAAAAxAhAAIEYAAgDECEAAgBgBCAAQIwABAGIEIABAjAAEAIixEDQwrLWdP/YeY6FoYEQCEBjWs3izEwhQZQoYACBGAAIAxAhAAIAYAQgAECMAAQBiBCAAQIwABACIEYAAADEWggYy1nb9WD5mYWigQAACGcu4sxMIUGUKGAAgRgACAMQIQACAGAEIABAjAAEAYgQgAECMAAQAiBGAAAAxFoIGhrW288feYywUDYxIAALDehZvdgIBqkwBAwDECEAAgBgBCAAQIwABAGIEIABAjAAEAIgRgAAAMQIQACDGQtBAxtquH8vHLAwNFAhAIGMZd3YCAapMAQMAxAhAAIAYAQgAECMAAQBiBCAAQIwABACIEYAAADECEAAgxkLQwLDWdv7Ye4yFooERCUBgWM/izU4gQJUpYACAGAEIABAjAAEAYgQgAECMAAQAiBGAAAAxAhAAIEYAAgDEWAgayFjb9WP5mIWhgQIBCGQs485OIECVKWAAgBgBCAAQIwABAGIEIABAjAAEAIhxFzBc0PLu1bPdzbq23MqZXt/Znf38nf3nD3hOAAKHW1tuhe2cP+DdBOCF3f+j4H/fAMBWAhAu6syjQt9+bXt+/63HfvI/Wd8+f1tc4TUCPxOAcEFXmCL85qj0CCPiZ/4arvDzB/ydALywM/8DAQCclwAE3mI5KuQ/LPs4f8A7TbO/VQAAUiwEDQAQIwABAGIEIABAjAAEAIgRgAAAMQIQPsiCua85+vyd/flqnD/4HAEIABAjAAEAYgQgAECMAAQAiBGAAAAxAhAAIEYAAgDECEAAgBgBCAAQ8+fbLwBq7HbwfnvO8dZj53k+/PcG+BYBCB92HxLTNB36/k9GOm6LPbG29ditzn7+3nncEe8Dn2EKGAAgRgACAMQIQACAGAEIX7S8zmrv+7/9fV519uc7u7Ofv6N+zt718wy8TgACAMQIQACAGAEIABAjAOHCznLt16eer+bs3w/fX7guAQgAEDPN/gsHAJBiBBAAIEYAAgDECEAAgBgBCAAQIwABAGL+fPsFADCmaZoeHrPwBJyDAATgLZaxtxaEwHeYAgYAiDECCAznHSNNI05d/uY87TkPRvzgvAQgMJytkTJN05Bht9VPX/uR56V8fuHMBCAAD5ajd0IOxiIAAXhwVPAJSTgnAQgQ965r9cQenJcABIizXAv0CEAAHpi6hbEJQAAeCD4YmwAEiDPlCz0CECDONYDQIwCBjLWwca3bOucFxiYAgYy1kS5hs855gbEJQIA4U77QIwAB4lwDCD0CEIAHrgGEsQlAAB4IPhibAASIM+ULPQIQOL21QDFCdZx3XQN4/zy+X3AuAhA4PTcpfN4R1wDePsf3C85HAALwwIgdjE0AAqf32xGkLZ/37JiRQ+hvX/tPHxv5fECJAAQu4ZUpyJ/UdwL56WuvnxcoEIAAPLAOIIxNAAKXIEg+64jze/89u73t+wbnIACB0xMN7/Wuu3R93+C8BCBAnGV2oEcAAvDAlDuMTQAC8EDwwdgEIECcKV/oEYAAca4BhB4BCGSshY1r3dY5LzA2AQhkrI10CZt1zguMTQACxJnyhR4BCBDnGkDo+efbLwCA17wj2KZp+r9frz4XcC5GAAF44BpAGJsRQIDBLEfctry/Z7Rv7/MD52MEECDONYDQYwQQgAdHXPsHnJcRQAAeuAYQxjbN/pQDgzpiBOsKf0VeYaTuCucRSowAAsN6Fh0j7QQyz/PD17P3/b2Pb33/CoEKNa4BBACIEYAAADECEAAgRgACDGJ53d7e97/9/MDnCEAAgBgBCHBxR4+0nf35gNcJQACAGAEIABBjIWggY21B4uVjpiuBAgEIZCzjbqSdQAD2MAUMABAjAAEAYgQgAECMAAQAiBGAAAAx7gIGTm95t667d//nfgmbI87H2jI5rzzv0a8POI4ABLioW1Sthdurz3nE877j9QHHMAUMABBjBBC4hN+MIm35nGfHmLoERiQAgdNb28HjN5+35FpCoMoUMABAjBFAgIu6Hwm9vf3qiOaRN2y84/UBx5hmfxqBKFPAQJUpYACAGAEIABAjAAEAYgQgAECMAAQAiLEMDJCxtsTJ8jF3BQMFAhDIWNtRRPABRaaAAQBiBCAAQIwABACIEYAAADECEAAgRgACAMQIQACAGAEIABBjIWhgWGs7f+w9xkLRwIgEIDCsZ/FmJxCgyhQwAECMAAQAiBGAAAAxAhAAIEYAAgDECEAAgBgBCAAQYx1AIGNt0eflY9YFBAoEIJCxjDsLQQNVpoABAGIEIABAjAAEAIgRgAAAMQIQACDGXcDA6a0t3+LuXYDfE4DAJQg+gOOYAgYAiDECCFzCb3bsWJs63nuMkUdgRAIQuIT7ENsSdsvPWWMnEKDKFDAAQIwRQOASto76AfCcAAROzzQtwLFMAQMAxAhAAIAYAQgAECMAAQBiBCAAQIy7gIGMtaVkfrPDCMDVCUAgYxl3dgIBqkwBAwDECEAAgBgBCAAQIwABAGIEIABAjAAEAIgRgAAAMQIQACDGQtDAsNZ2/th7jIWigREJQGBYz+LNTiBAlSlgAIAYAQgAECMAAQBiBCAAQIwABACIEYAAADECEAAgRgACAMRYCBrIWNv1Y/mYhaGBAgEIZCzjzk4gQJUpYACAGAEIABAjAAEAYgQgAECMAAQAiHEXMHB6a8u3uHsX4PcEIHAJ98G3FoQAbGcKGAAgZprNowAXcD/qt/WvrSNGCv0VCYzIFDBwessdO7bu4PHsGDuBAFWmgAEAYowAApfgxg+A4whA4PRM0wIcyxQwAECMAAQAiBGAAAAxAhAAIEYAAgDEuAsYyFhbSmb5mDuOgQIBCGQs485OIECVKWAAgBgBCAAQIwABAGIEIABAjAAEAIgRgAAAMQIQACBGAAIAxFgIGhjW2s4fe4+xUDQwIgEIDOtZvNkJBKgyBQwAECMAAQBiBCAAQIwABACIEYAAADECEAAgRgACAMQIQACAGAtBAxlru34sH7MwNFAgAIGMZdzZCQSoMgUMABAjAAEAYgQgAECMAAQAiBGAAAAx7gIGvu5+KZa1u3LXlm9x9y7A7wlA4OtuMbcWestjnh0HwHOmgAEAYowAAsPZM0K49VhTzsBIBCAwHLEG8HemgAEAYowAAl93Pw17e3tt314AjjHN5koAAFJMAQMAxAhAAIAYAQgAECMAAQBiBCAAQIwABACIEYAAADECEAAgRgACAMQIQACAGAEIABAjAAEAYgQgAECMAAQAiBGAAAAxAhAAIEYAAgDECEAAgBgBCAAQIwABAGIEIABAjAAEAIgRgAAAMQIQACBGAAIAxAhAAIAYAQgAECMAAQBiBCAAQIwABACIEYAAADECEAAgRgACAMQIQACAGAEIABAjAAEAYv4LAxlfdXtCUSQAAAAASUVORK5CYII=',
                },
            ],
        },
    },
};