/*
 * Copyright (c) 2015 Sinch AB. All rights reserved.
 *
 * See LICENSE file for license terms and information.
 */

#ifndef SIN_EXPORT
#define SIN_EXPORT __attribute__((visibility("default")))
#endif

#ifndef SIN_EXTERN
#ifdef __cplusplus
#define SIN_EXTERN extern "C"
#else
#define SIN_EXTERN extern
#endif
#endif
