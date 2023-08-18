import React from 'react';
import { DefaultCard, DefaultRow, SeparateRow } from '@/components/container/defaultBox';
import { Text20, TextSemiBold24 } from '@/components/text/styled';
import { DefaultButton } from '@/components/button/style';
import { ButtonText } from '@/components/profile/components/style';
import { IRiffle } from '@/interface/profile';
import { WithId } from '@/interface/helper';

export const Rifle: React.FC<WithId<IRiffle>> = ({ scHeight, rTwist, twistDir, caliber, id }) => {
    console.log(id);

    return (
        <DefaultCard>
            <SeparateRow>
                <TextSemiBold24>Rifle</TextSemiBold24>
                <DefaultButton>
                    <ButtonText>Edit</ButtonText>
                </DefaultButton>
            </SeparateRow>

            <DefaultRow>
                <Text20>Calibre:</Text20>
                <Text20>{caliber}</Text20>
            </DefaultRow>

            <DefaultRow>
                <Text20>Twist direction:</Text20>
                <Text20>{twistDir}</Text20>
            </DefaultRow>

            <DefaultRow>
                <Text20>Twist rate:</Text20>
                <Text20>{rTwist} inches/turn</Text20>
            </DefaultRow>

            <DefaultRow>
                <Text20>Scope height:</Text20>
                <Text20>{scHeight} mm</Text20>
            </DefaultRow>
        </DefaultCard>
    );
};
