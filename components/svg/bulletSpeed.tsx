import React from 'react';
import Svg, { Path, Rect, G } from 'react-native-svg';
import { BaseSVGProps } from '@/interface/svg';

export const BulletSpeedSVG: React.FC<BaseSVGProps> = ({ width, height, fillColor }) => {
    return (
        <Svg
            fill={fillColor}
            id="Capa_1"
            xmlns="http://www.w3.org/2000/svg"
            width={width}
            height={height}
            viewBox="0 0 99.578 99.578">
            <G>
                <G>
                    <Path
                        d="M48.199,45.317c-0.672-2.817-1.922-4.717-3.357-4.717v18.844c1.436,0,2.686-1.899,3.357-4.717v4.722h34.66v-3.308H58.891
			c-1.729,0-3.131-1.401-3.131-3.129c0-1.73,1.4-3.132,3.131-3.132h23.969v-1.063H58.004c-0.393,0-0.709-0.317-0.709-0.709
			s0.316-0.708,0.709-0.708h24.855v-7.088h-34.66V45.317z"
                    />
                    <Path d="M85.104,40.128v18.957c7.996,0,14.475-4.243,14.475-9.479S93.1,40.128,85.104,40.128z" />
                    <Rect x="1.064" y="40.667" width="33.666" height="1.418" />
                    <Rect x="14.176" y="47.046" width="24.453" height="1.417" />
                    <Rect x="15.416" y="50.058" width="16.125" height="1.418" />
                    <Rect y="54.312" width="30.125" height="1.416" />
                </G>
            </G>
        </Svg>
    );
};
