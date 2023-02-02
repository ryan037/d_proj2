#ifndef VALUES_H
#define VALUES_H

#include<iostream>

enum ValueType
{
    type_integer = 0,
    type_real = 1,
    type_bool = 2,
    type_string = 3,
    type_void = 4,
    type_array = 5
};

enum EntryType
{
    Constant = 0,
    Variable = 1,
    Argument = 2,
    Function = 3
};
/*
inline std::string EnumToString(const ValueType value)
{
    switch (value)
    {
    case ValueType::type_class:
        return "class";
    case ValueType::type_function:
        return "function";
    case ValueType::type_integer:
        return "int";
    case ValueType::type_real:
        return "double";
    case ValueType::type_string:
        return "string";
    case ValueType::type_void:
        return "void";
    default:
        return std::to_string(value);
    }
}*/
#endif
