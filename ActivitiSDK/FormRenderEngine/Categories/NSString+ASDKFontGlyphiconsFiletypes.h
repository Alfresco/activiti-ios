/*******************************************************************************
 * Copyright (C) 2005-2016 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Activiti Mobile SDK.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ******************************************************************************/

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ASDKGlyphIconFileType) {
    ASDKGlyphIconFileTypeUndefined = -1,
    ASDKGlyphIconFileTypeTxt       = 0,
    ASDKGlyphIconFileTypeDoc,
    ASDKGlyphIconFileTypeRtf,
    ASDKGlyphIconFileTypeLog,
    ASDKGlyphIconFileTypeTex,
    ASDKGlyphIconFileTypeMsg,
    ASDKGlyphIconFileTypeText,
    ASDKGlyphIconFileTypeWpd,
    ASDKGlyphIconFileTypeWps,
    ASDKGlyphIconFileTypeDocx,
    ASDKGlyphIconFileTypePage,
    ASDKGlyphIconFileTypeCsv,
    ASDKGlyphIconFileTypeDat,
    ASDKGlyphIconFileTypeTar,
    ASDKGlyphIconFileTypeXml,
    ASDKGlyphIconFileTypeVcf,
    ASDKGlyphIconFileTypePps,
    ASDKGlyphIconFileTypeKey,
    ASDKGlyphIconFileTypePpt,
    ASDKGlyphIconFileTypePptx,
    ASDKGlyphIconFileTypeSdf,
    ASDKGlyphIconFileTypeGbr,
    ASDKGlyphIconFileTypeGed,
    ASDKGlyphIconFileTypeMp3,
    ASDKGlyphIconFileTypeM4a,
    ASDKGlyphIconFileTypeWaw,
    ASDKGlyphIconFileTypeWma,
    ASDKGlyphIconFileTypeMpa,
    ASDKGlyphIconFileTypeIff,
    ASDKGlyphIconFileTypeAif,
    ASDKGlyphIconFileTypeRa,
    ASDKGlyphIconFileTypeMid,
    ASDKGlyphIconFileTypeM3v,
    ASDKGlyphIconFileTypeE3gp,
    ASDKGlyphIconFileTypeSwf,
    ASDKGlyphIconFileTypeAvi,
    ASDKGlyphIconFileTypeAsx,
    ASDKGlyphIconFileTypeMp4,
    ASDKGlyphIconFileTypeE3g2,
    ASDKGlyphIconFileTypeMpg,
    ASDKGlyphIconFileTypeAsf,
    ASDKGlyphIconFileTypeVob,
    ASDKGlyphIconFileTypeWmv,
    ASDKGlyphIconFileTypeMov,
    ASDKGlyphIconFileTypeSrt,
    ASDKGlyphIconFileTypeM4v,
    ASDKGlyphIconFileTypeFlv,
    ASDKGlyphIconFileTypeRm,
    ASDKGlyphIconFileTypePng,
    ASDKGlyphIconFileTypePsd,
    ASDKGlyphIconFileTypePsp,
    ASDKGlyphIconFileTypeJpg,
    ASDKGlyphIconFileTypeTif,
    ASDKGlyphIconFileTypeTiff,
    ASDKGlyphIconFileTypeGif,
    ASDKGlyphIconFileTypeBmp,
    ASDKGlyphIconFileTypeTga,
    ASDKGlyphIconFileTypeThm,
    ASDKGlyphIconFileTypeYuv,
    ASDKGlyphIconFileTypeDds,
    ASDKGlyphIconFileTypeAi,
    ASDKGlyphIconFileTypeEps,
    ASDKGlyphIconFileTypePs,
    ASDKGlyphIconFileTypeSvg,
    ASDKGlyphIconFileTypePdf,
    ASDKGlyphIconFileTypePct,
    ASDKGlyphIconFileTypeIndd,
    ASDKGlyphIconFileTypeXlr,
    ASDKGlyphIconFileTypeXls,
    ASDKGlyphIconFileTypeXlsx,
    ASDKGlyphIconFileTypeDb,
    ASDKGlyphIconFileTypeDbf,
    ASDKGlyphIconFileTypeMdb,
    ASDKGlyphIconFileTypePdb,
    ASDKGlyphIconFileTypeSql,
    ASDKGlyphIconFileTypeAacd,
    ASDKGlyphIconFileTypeApp,
    ASDKGlyphIconFileTypeExe,
    ASDKGlyphIconFileTypeCom,
    ASDKGlyphIconFileTypeBat,
    ASDKGlyphIconFileTypeApk,
    ASDKGlyphIconFileTypeJar,
    ASDKGlyphIconFileTypeHsf,
    ASDKGlyphIconFileTypePif,
    ASDKGlyphIconFileTypeVb,
    ASDKGlyphIconFileTypeCgi,
    ASDKGlyphIconFileTypeCss,
    ASDKGlyphIconFileTypeJs,
    ASDKGlyphIconFileTypePhp,
    ASDKGlyphIconFileTypeXhtml,
    ASDKGlyphIconFileTypeHtm,
    ASDKGlyphIconFileTypeHtml,
    ASDKGlyphIconFileTypeAsp,
    ASDKGlyphIconFileTypeCer,
    ASDKGlyphIconFileTypeJsp,
    ASDKGlyphIconFileTypeCfm,
    ASDKGlyphIconFileTypeAspx,
    ASDKGlyphIconFileTypeRss,
    ASDKGlyphIconFileTypeCsr,
    ASDKGlyphIconFileTypeLess,
    ASDKGlyphIconFileTypeOtf,
    ASDKGlyphIconFileTypeTtf,
    ASDKGlyphIconFileTypeFont,
    ASDKGlyphIconFileTypeFnt,
    ASDKGlyphIconFileTypeEot,
    ASDKGlyphIconFileTypeWoff,
    ASDKGlyphIconFileTypeZip,
    ASDKGlyphIconFileTypeZipx,
    ASDKGlyphIconFileTypeRar,
    ASDKGlyphIconFileTypeTarg,
    ASDKGlyphIconFileTypeSitx,
    ASDKGlyphIconFileTypeDeb,
    ASDKGlyphIconFileTypeE7z,
    ASDKGlyphIconFileTypePkg,
    ASDKGlyphIconFileTypeRpm,
    ASDKGlyphIconFileTypeCbr,
    ASDKGlyphIconFileTypeGz,
    ASDKGlyphIconFileTypeDmg,
    ASDKGlyphIconFileTypeCue,
    ASDKGlyphIconFileTypeBin,
    ASDKGlyphIconFileTypeIso,
    ASDKGlyphIconFileTypeHdf,
    ASDKGlyphIconFileTypeVcd,
    ASDKGlyphIconFileTypeBak,
    ASDKGlyphIconFileTypeTmp,
    ASDKGlyphIconFileTypeIcs,
    ASDKGlyphIconFileTypeMsi,
    ASDKGlyphIconFileTypeCfg,
    ASDKGlyphIconFileTypeIni,
    ASDKGlyphIconFileTypePrf
};

@interface NSString (ASDKFontGlyphiconsFiletypes)

+ (NSString *)fileTypeIconStringForIconType:(ASDKGlyphIconFileType)iconType;
+ (ASDKGlyphIconFileType)fileTypeIconForIcontDescription:(NSString *)iconDescription;

@end