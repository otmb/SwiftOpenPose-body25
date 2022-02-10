// Copyright (C) 2018-2022 Intel Corporation
// SPDX-License-Identifier: Apache-2.0
//

/**
 * @brief a header file with common samples functionality
 * @file common.hpp
 */

#pragma once
#include <iostream>

template <typename T, std::size_t N>
constexpr std::size_t arraySize(const T(&)[N]) noexcept {
    return N;
}
