import React, { useState } from 'react';
import { NumericInputProps } from '@/interface/components/input';
import { Container, Input, InputError, InputLabel, InputUnit, InputWrapper, UintText } from './style';
import { regexNumeric } from '@/constant/regex';

export const NumericInput: React.FC<NumericInputProps> = ({
    style,
    touched,
    background,
    label,
    error,
    value,
    onChangeText,
    onBlur,
    schema,
    uint,
}) => {
    const [isActive, setIsActive] = useState(!!value);
    const [handleError, setHandleError] = useState('');
    const handleFocus = () => {
        setIsActive(true);
        setHandleError('');
    };

    const handleBlur = async (str: string) => {
        onBlur(str);
        if (schema) {
            try {
                await schema.validate(value);
            } catch (e: any) {
                setHandleError(e.errors[0]);
            }
        }

        if (value === '') {
            setIsActive(false);
        }
    };

    const handleOnChangeText = (text: string) => {
        if (text.length === 0) {
            onChangeText(text);
        }
        if (text.length === 1 && text === '-') {
            onChangeText(text);
        }

        const newText = text.replace(',', '.');

        const lastIndex = newText.length - 1;
        const lastLetter = newText.at(-1);
        if (lastLetter === '.' && newText.indexOf('.') === lastIndex) {
            onChangeText(newText);
            return;
        }

        if (regexNumeric.test(text)) {
            onChangeText(newText);
        }
    };

    return (
        <Container style={style}>
            <InputWrapper>
                <InputLabel isActive={isActive} background={background}>
                    {label}
                </InputLabel>
                <Input
                    value={value}
                    onFocus={handleFocus}
                    onBlur={handleBlur}
                    keyboardType="numeric"
                    onChangeText={handleOnChangeText}
                />
                {!!uint && (
                    <InputUnit>
                        <UintText>{uint}</UintText>
                    </InputUnit>
                )}
            </InputWrapper>
            {((touched && !!error) || !!handleError) && <InputError>{error || handleError}</InputError>}
        </Container>
    );
};
