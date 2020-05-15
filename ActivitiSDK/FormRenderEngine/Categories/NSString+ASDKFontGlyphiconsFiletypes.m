/*******************************************************************************
 * Copyright (C) 2005-2020 Alfresco Software Limited.
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

#import "NSString+ASDKFontGlyphiconsFiletypes.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@implementation NSString (ASDKFontGlyphiconsFiletypes)


#pragma mark -
#pragma mark Public interface

+ (NSString *)fileTypeIconStringForIconType:(ASDKGlyphIconFileType)iconType {
    if (ASDKGlyphIconFileTypeUndefined != iconType) {
        return [NSString fontGlyphiconsFiletypesUnicodeStrings][iconType];
    }
    return nil;
}

+ (ASDKGlyphIconFileType)fileTypeIconForIcontDescription:(NSString *)iconDescription {
    // First check if icon description is registered
    NSNumber *iconDescriptionCorrespondentValue = [self fileTypeIconDescriptions][iconDescription];
    if (iconDescriptionCorrespondentValue) {
        return (ASDKGlyphIconFileType)[iconDescriptionCorrespondentValue integerValue];
    }
    
    return ASDKGlyphIconFileTypeUndefined;
}


#pragma mark -
#pragma mark Private interface

+ (NSArray *)fontGlyphiconsFiletypesUnicodeStrings {
    static NSArray *fontGlyphiconsUnicodeStrings;
    
    static dispatch_once_t unicodeStringsOnceToken;
    dispatch_once(&unicodeStringsOnceToken, ^{
        fontGlyphiconsUnicodeStrings = @[@"\uE001",@"\uE002",@"\uE003",@"\uE004",@"\uE005",@"\uE006",@"\uE007",@"\uE008",@"\uE009",@"\uE010",@"\u2709",@"\uE012",@"\uE013",@"\uE014",@"\uE015",@"\uE016",@"\uE017",@"\uE018",@"\uE019",@"\uE020",@"\uE021",@"\uE022",@"\uE023",@"\uE024",@"\uE025",@"\uE026",@"\uE027",@"\uE028",@"\uE029",@"\uE030",@"\u270F",@"\uE032",@"\uE033",@"\uE034",@"\uE035",@"\uE036",@"\uE037",@"\uE038",@"\uE039",@"\uE040",@"\uE041",@"\uE042",@"\uE043",@"\uE044",@"\uE045",@"\uE046",@"\uE047",@"\uE048",@"\uE049",@"\uE050",@"\uE051",@"\uE052",@"\uE053",@"\uE054",@"\uE055",@"\uE056",@"\uE057",@"\uE058",@"\uE059",@"\uE060",@"\uE061",@"\uE062",@"\uE063",@"\uE064",@"\uE065",@"\uE066",@"\uE067",@"\uE068",@"\uE069",@"\uE070",@"\uE071",@"\uE072",@"\uE073",@"\uE074",@"\uE075",@"\uE076",@"\uE077",@"\uE078",@"\uE079",@"\uE080",@"\uE081",@"\uE082",@"\uE083",@"\uE084",@"\uE085",@"\uE086",@"\uE087",@"\uE088",@"\uE089",@"\uE090",@"\uE091",@"\uE092",@"\uE093",@"\uE094",@"\uE095",@"\uE096",@"\uE097",@"\uE098",@"\uE099",@"\uE100",@"\uE101",@"\uE102",@"\uE103",@"\uE104",@"\uE105",@"\uE106",@"\uE107",@"\uE108",@"\uE109",@"\uE110",@"\uE111",@"\uE112",@"\uE113",@"\uE114",@"\uE115",@"\uE116",@"\uE117",@"\uE118",@"\uE119",@"\uE120",@"\uE121",@"\uE122",@"\uE123",@"\uE124",@"\uE125",@"\uE126",@"\uE127",@"\uE128",@"\uE129",@"\uE130"];
    });
    
    return fontGlyphiconsUnicodeStrings;
}

+ (NSDictionary *)fileTypeIconDescriptions {
    static NSDictionary *iconsDescriptionsDict;
    
    static dispatch_once_t iconDescriptionsOnceToken;
    dispatch_once(&iconDescriptionsOnceToken, ^{
        iconsDescriptionsDict = @{
                                  @"doc"				: @(ASDKGlyphIconFileTypeDoc),
                                  @"rtf"				: @(ASDKGlyphIconFileTypeRtf),
                                  @"log"				: @(ASDKGlyphIconFileTypeLog),
                                  @"tex"				: @(ASDKGlyphIconFileTypeTex),
                                  @"msg"				: @(ASDKGlyphIconFileTypeMsg),
                                  @"text"				: @(ASDKGlyphIconFileTypeText),
                                  @"wpd"				: @(ASDKGlyphIconFileTypeWpd),
                                  @"wps"				: @(ASDKGlyphIconFileTypeWps),
                                  @"docx"				: @(ASDKGlyphIconFileTypeDocx),
                                  @"page"				: @(ASDKGlyphIconFileTypePage),
                                  @"csv"				: @(ASDKGlyphIconFileTypeCsv),
                                  @"dat"				: @(ASDKGlyphIconFileTypeDat),
                                  @"tar"				: @(ASDKGlyphIconFileTypeTar),
                                  @"xml"				: @(ASDKGlyphIconFileTypeXml),
                                  @"vcf"				: @(ASDKGlyphIconFileTypeVcf),
                                  @"pps"				: @(ASDKGlyphIconFileTypePps),
                                  @"key"				: @(ASDKGlyphIconFileTypeKey),
                                  @"ppt"				: @(ASDKGlyphIconFileTypePpt),
                                  @"pptx"				: @(ASDKGlyphIconFileTypePptx),
                                  @"sdf"				: @(ASDKGlyphIconFileTypeSdf),
                                  @"gbr"				: @(ASDKGlyphIconFileTypeGbr),
                                  @"ged"				: @(ASDKGlyphIconFileTypeGed),
                                  @"mp3"				: @(ASDKGlyphIconFileTypeMp3),
                                  @"m4a"				: @(ASDKGlyphIconFileTypeM4a),
                                  @"waw"				: @(ASDKGlyphIconFileTypeWaw),
                                  @"wma"				: @(ASDKGlyphIconFileTypeWma),
                                  @"mpa"				: @(ASDKGlyphIconFileTypeMpa),
                                  @"iff"				: @(ASDKGlyphIconFileTypeIff),
                                  @"aif"				: @(ASDKGlyphIconFileTypeAif),
                                  @"ra"                 : @(ASDKGlyphIconFileTypeRa),
                                  @"mid"				: @(ASDKGlyphIconFileTypeMid),
                                  @"m3v"				: @(ASDKGlyphIconFileTypeM3v),
                                  @"e-3gp"				: @(ASDKGlyphIconFileTypeE3gp),
                                  @"swf"				: @(ASDKGlyphIconFileTypeSwf),
                                  @"avi"				: @(ASDKGlyphIconFileTypeAvi),
                                  @"asx"				: @(ASDKGlyphIconFileTypeAsx),
                                  @"mp4"				: @(ASDKGlyphIconFileTypeMp4),
                                  @"e-3g2"				: @(ASDKGlyphIconFileTypeE3g2),
                                  @"mpg"				: @(ASDKGlyphIconFileTypeMpg),
                                  @"asf"				: @(ASDKGlyphIconFileTypeAsf),
                                  @"vob"				: @(ASDKGlyphIconFileTypeVob),
                                  @"wmv"				: @(ASDKGlyphIconFileTypeWmv),
                                  @"mov"				: @(ASDKGlyphIconFileTypeMov),
                                  @"srt"				: @(ASDKGlyphIconFileTypeSrt),
                                  @"m4v"				: @(ASDKGlyphIconFileTypeM4v),
                                  @"flv"				: @(ASDKGlyphIconFileTypeFlv),
                                  @"rm"                 : @(ASDKGlyphIconFileTypeRm),
                                  @"png"				: @(ASDKGlyphIconFileTypePng),
                                  @"psd"				: @(ASDKGlyphIconFileTypePsd),
                                  @"psp"				: @(ASDKGlyphIconFileTypePsp),
                                  @"jpg"				: @(ASDKGlyphIconFileTypeJpg),
                                  @"tif"				: @(ASDKGlyphIconFileTypeTif),
                                  @"tiff"				: @(ASDKGlyphIconFileTypeTiff),
                                  @"gif"				: @(ASDKGlyphIconFileTypeGif),
                                  @"bmp"				: @(ASDKGlyphIconFileTypeBmp),
                                  @"tga"				: @(ASDKGlyphIconFileTypeTga),
                                  @"thm"				: @(ASDKGlyphIconFileTypeThm),
                                  @"yuv"				: @(ASDKGlyphIconFileTypeYuv),
                                  @"dds"				: @(ASDKGlyphIconFileTypeDds),
                                  @"ai"                 : @(ASDKGlyphIconFileTypeAi),
                                  @"eps"				: @(ASDKGlyphIconFileTypeEps),
                                  @"ps"                 : @(ASDKGlyphIconFileTypePs),
                                  @"svg"				: @(ASDKGlyphIconFileTypeSvg),
                                  @"pdf"				: @(ASDKGlyphIconFileTypePdf),
                                  @"pct"				: @(ASDKGlyphIconFileTypePct),
                                  @"indd"				: @(ASDKGlyphIconFileTypeIndd),
                                  @"xlr"				: @(ASDKGlyphIconFileTypeXlr),
                                  @"xls"				: @(ASDKGlyphIconFileTypeXls),
                                  @"xlsx"				: @(ASDKGlyphIconFileTypeXlsx),
                                  @"db"                 : @(ASDKGlyphIconFileTypeDb),
                                  @"dbf"				: @(ASDKGlyphIconFileTypeDbf),
                                  @"mdb"				: @(ASDKGlyphIconFileTypeMdb),
                                  @"pdb"				: @(ASDKGlyphIconFileTypePdb),
                                  @"sql"				: @(ASDKGlyphIconFileTypeSql),
                                  @"aacd"				: @(ASDKGlyphIconFileTypeAacd),
                                  @"app"				: @(ASDKGlyphIconFileTypeApp),
                                  @"exe"				: @(ASDKGlyphIconFileTypeExe),
                                  @"com"				: @(ASDKGlyphIconFileTypeCom),
                                  @"bat"				: @(ASDKGlyphIconFileTypeBat),
                                  @"apk"				: @(ASDKGlyphIconFileTypeApk),
                                  @"jar"				: @(ASDKGlyphIconFileTypeJar),
                                  @"hsf"				: @(ASDKGlyphIconFileTypeHsf),
                                  @"pif"				: @(ASDKGlyphIconFileTypePif),
                                  @"vb"                 : @(ASDKGlyphIconFileTypeVb),
                                  @"cgi"				: @(ASDKGlyphIconFileTypeCgi),
                                  @"css"				: @(ASDKGlyphIconFileTypeCss),
                                  @"js"                 : @(ASDKGlyphIconFileTypeJs),
                                  @"php"				: @(ASDKGlyphIconFileTypePhp),
                                  @"xhtml"				: @(ASDKGlyphIconFileTypeXhtml),
                                  @"htm"				: @(ASDKGlyphIconFileTypeHtm),
                                  @"html"				: @(ASDKGlyphIconFileTypeHtml),
                                  @"asp"				: @(ASDKGlyphIconFileTypeAsp),
                                  @"cer"				: @(ASDKGlyphIconFileTypeCer),
                                  @"jsp"				: @(ASDKGlyphIconFileTypeJsp),
                                  @"cfm"				: @(ASDKGlyphIconFileTypeCfm),
                                  @"aspx"				: @(ASDKGlyphIconFileTypeAspx),
                                  @"rss"				: @(ASDKGlyphIconFileTypeRss),
                                  @"csr"				: @(ASDKGlyphIconFileTypeCsr),
                                  @"less"				: @(ASDKGlyphIconFileTypeLess),
                                  @"otf"				: @(ASDKGlyphIconFileTypeOtf),
                                  @"ttf"				: @(ASDKGlyphIconFileTypeTtf),
                                  @"font"				: @(ASDKGlyphIconFileTypeFont),
                                  @"fnt"				: @(ASDKGlyphIconFileTypeFnt),
                                  @"eot"				: @(ASDKGlyphIconFileTypeEot),
                                  @"woff"				: @(ASDKGlyphIconFileTypeWoff),
                                  @"zip"				: @(ASDKGlyphIconFileTypeZip),
                                  @"zipx"				: @(ASDKGlyphIconFileTypeZipx),
                                  @"rar"				: @(ASDKGlyphIconFileTypeRar),
                                  @"targ"				: @(ASDKGlyphIconFileTypeTarg),
                                  @"sitx"				: @(ASDKGlyphIconFileTypeSitx),
                                  @"deb"				: @(ASDKGlyphIconFileTypeDeb),
                                  @"e-7z"				: @(ASDKGlyphIconFileTypeE7z),
                                  @"pkg"				: @(ASDKGlyphIconFileTypePkg),
                                  @"rpm"				: @(ASDKGlyphIconFileTypeRpm),
                                  @"cbr"				: @(ASDKGlyphIconFileTypeCbr),
                                  @"gz"                 : @(ASDKGlyphIconFileTypeGz),
                                  @"dmg"				: @(ASDKGlyphIconFileTypeDmg),
                                  @"cue"				: @(ASDKGlyphIconFileTypeCue),
                                  @"bin"				: @(ASDKGlyphIconFileTypeBin),
                                  @"iso"				: @(ASDKGlyphIconFileTypeIso),
                                  @"hdf"				: @(ASDKGlyphIconFileTypeHdf),
                                  @"vcd"				: @(ASDKGlyphIconFileTypeVcd),
                                  @"bak"				: @(ASDKGlyphIconFileTypeBak),
                                  @"tmp"				: @(ASDKGlyphIconFileTypeTmp),
                                  @"ics"				: @(ASDKGlyphIconFileTypeIcs),
                                  @"msi"				: @(ASDKGlyphIconFileTypeMsi),
                                  @"cfg"				: @(ASDKGlyphIconFileTypeCfg),
                                  @"ini"				: @(ASDKGlyphIconFileTypeIni),
                                  @"prf"				: @(ASDKGlyphIconFileTypePrf)
                                 };
    });
    
    return iconsDescriptionsDict;
}

@end
