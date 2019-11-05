/*******************************************************************************
 * Copyright (C) 2005-2018 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Activiti Mobile iOS App.
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

import Foundation
import MaterialComponents.MDCContainerScheme

class MaterialDesignColorSchemeComponent: NSObject {
    
    override init() {
        self.flatButtonWithBackgroundScheme.colorScheme = self.defaultColorScheme
        self.flatButtonWithBackgroundScheme.typographyScheme = self.boldTypographyScheme
        
        self.flatButtonWithoutBackgroundScheme.colorScheme = self.defaultColorScheme
        self.flatButtonWithoutBackgroundScheme.typographyScheme = self.defaultTypographyScheme
        
        self.highlighterFlatButtonWithBackgroundScheme.colorScheme = self.defaultColorScheme
        self.highlighterFlatButtonWithBackgroundScheme.typographyScheme = self.boldTypographyScheme
        
        self.grayFlatButtonWithoutBackgroundScheme.colorScheme = self.grayColorScheme
        self.grayFlatButtonWithoutBackgroundScheme.typographyScheme = self.defaultTypographyScheme
        
        self.blueFlatButtonWithoutBackgroundScheme.colorScheme = self.blueColorScheme
        self.blueFlatButtonWithoutBackgroundScheme.typographyScheme = self.defaultTypographyScheme
        
        super.init()
    }
    
    public let flatButtonWithBackgroundScheme = MDCContainerScheme()
    public let flatButtonWithoutBackgroundScheme = MDCContainerScheme()
    public let highlighterFlatButtonWithBackgroundScheme = MDCContainerScheme()
    public let grayFlatButtonWithoutBackgroundScheme = MDCContainerScheme()
    public let blueFlatButtonWithoutBackgroundScheme = MDCContainerScheme()
    
    public let defaultColorScheme: MDCSemanticColorScheme = {
        let scheme = MDCSemanticColorScheme(defaults: .material201804)
        scheme.primaryColor = #colorLiteral(red: 0.2474783659, green: 0.6575964093, blue: 0.2639612854, alpha: 1)
        scheme.primaryColorVariant = #colorLiteral(red: 0, green: 0.4588235294, blue: 0.2901960784, alpha: 1)
        scheme.onPrimaryColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        scheme.secondaryColor = #colorLiteral(red: 0, green: 0.3333333333, blue: 0.7215686275, alpha: 1)
        scheme.onSecondaryColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        scheme.surfaceColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        scheme.onSurfaceColor = #colorLiteral(red: 0.2474783659, green: 0.6575964093, blue: 0.2639612854, alpha: 1)
        scheme.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        scheme.onBackgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.72)
        scheme.errorColor = #colorLiteral(red: 1, green: 0.2470588235, blue: 0.2666666667, alpha: 1)
        
        return scheme
    }()
    
    public let advancedSettingsTextFieldColorScheme: MDCSemanticColorScheme = {
        let scheme = MDCSemanticColorScheme(defaults: .material201804)
        scheme.primaryColor = #colorLiteral(red: 0.2474783659, green: 0.6575964093, blue: 0.2639612854, alpha: 1)
        scheme.primaryColorVariant = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        scheme.errorColor = #colorLiteral(red: 1, green: 0.2470588235, blue: 0.2666666667, alpha: 1)
        
        return scheme
    }()
    
    public let grayColorScheme: MDCSemanticColorScheme = {
        let scheme = MDCSemanticColorScheme(defaults: .material201804)
        scheme.primaryColor = #colorLiteral(red: 0.2941176471, green: 0.2784313725, blue: 0.2862745098, alpha: 1)
        scheme.primaryColorVariant = #colorLiteral(red: 0, green: 0.4588235294, blue: 0.2901960784, alpha: 1)
        scheme.onPrimaryColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        scheme.secondaryColor = #colorLiteral(red: 0, green: 0.3333333333, blue: 0.7215686275, alpha: 1)
        scheme.onSecondaryColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        scheme.surfaceColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        scheme.onSurfaceColor = #colorLiteral(red: 0.2474783659, green: 0.6575964093, blue: 0.2639612854, alpha: 1)
        scheme.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        scheme.onBackgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.72)
        scheme.errorColor = #colorLiteral(red: 1, green: 0.2470588235, blue: 0.2666666667, alpha: 1)
        
        return scheme
    }()
    
    public let blueColorScheme: MDCSemanticColorScheme = {
        let scheme = MDCSemanticColorScheme(defaults: .material201804)
        scheme.primaryColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
        scheme.primaryColorVariant = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        scheme.onPrimaryColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        scheme.secondaryColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        scheme.onSecondaryColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        scheme.surfaceColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        scheme.onSurfaceColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        scheme.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        scheme.onBackgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        scheme.errorColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        
        return scheme
    }()
    
    public let defaultErrorColorScheme: MDCSemanticColorScheme = {
        let scheme = MDCSemanticColorScheme(defaults: .material201804)
        scheme.primaryColor = #colorLiteral(red: 1, green: 0.2470588235, blue: 0.2666666667, alpha: 1)
        scheme.primaryColorVariant = #colorLiteral(red: 0, green: 0.4588235294, blue: 0.2901960784, alpha: 1)
        scheme.onPrimaryColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        scheme.secondaryColor = #colorLiteral(red: 0, green: 0.3333333333, blue: 0.7215686275, alpha: 1)
        scheme.onSecondaryColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        scheme.surfaceColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        scheme.onSurfaceColor = #colorLiteral(red: 1, green: 0.2470588235, blue: 0.2666666667, alpha: 1)
        scheme.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        scheme.onBackgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.72)
        scheme.errorColor = #colorLiteral(red: 1, green: 0.2470588235, blue: 0.2666666667, alpha: 1)
        
        return scheme
    } ()
    
    public let defaultTypographyScheme: MDCTypographyScheme = {
        let scheme = MDCTypographyScheme()
        
        let lightFontName = "Muli-Light"
        let boldFontName = "Muli-Bold"
        
        scheme.headline6 = UIFont(name: lightFontName, size: 20)!
        scheme.headline5 = UIFont(name: lightFontName, size: 25)!
        scheme.headline4 = UIFont(name: boldFontName, size: 24)!
        scheme.subtitle1 = UIFont(name: lightFontName, size: 12)!
        scheme.button = UIFont(name: lightFontName, size: 14)!
        scheme.subtitle2 = UIFont(name: lightFontName, size: 16)!
        
        return scheme
    }()
    
    public let textFieldTypographyScheme: MDCTypographyScheme = {
        let scheme = MDCTypographyScheme()
        
        let lightFontName = "Muli-Light"
        let boldFontName = "Muli-Bold"
        
        scheme.headline1 = UIFont(name: lightFontName, size: 16)!
        scheme.subtitle1 = UIFont(name: lightFontName, size: 16)!
        scheme.subtitle2 = UIFont(name: lightFontName, size: 1)!
        
        return scheme
    }()
    
    public let boldTypographyScheme: MDCTypographyScheme = {
       let scheme = MDCTypographyScheme()
        
        let boldFontName = "Muli-Bold"
        scheme.button = UIFont(name: boldFontName, size: 14)!
        
        return scheme
    }()
    
    public let defaultShapeScheme: MDCShapeScheming = {
        let scheme = MDCShapeScheme()
        return scheme
    }()
}
