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
        
        self.flatButtonWithoutBackgroundScheme.colorScheme = self.flatButtonWithoutBackgroundColorScheme
        self.flatButtonWithoutBackgroundScheme.typographyScheme = self.defaultTypographyScheme
        
        self.highlightedFlatButtonWithBackgroundScheme.colorScheme = self.flatButtonWithoutBackgroundColorScheme
        self.highlightedFlatButtonWithBackgroundScheme.typographyScheme = self.defaultTypographyScheme
        
        self.grayFlatButtonWithoutBackgroundScheme.colorScheme = self.grayColorScheme
        self.grayFlatButtonWithoutBackgroundScheme.typographyScheme = self.defaultTypographyScheme
        
        self.blueFlatButtonWithoutBackgroundScheme.colorScheme = self.blueColorScheme
        self.blueFlatButtonWithoutBackgroundScheme.typographyScheme = self.defaultTypographyScheme
        
        self.greenFlatButtonWithoutBackgroundScheme.colorScheme = self.greenColorScheme
        self.greenFlatButtonWithoutBackgroundScheme.typographyScheme = self.defaultTypographyScheme
        
        super.init()
    }
    
    public let flatButtonWithBackgroundScheme = MDCContainerScheme()
    public let flatButtonWithoutBackgroundScheme = MDCContainerScheme()
    public let highlightedFlatButtonWithBackgroundScheme = MDCContainerScheme()
    public let grayFlatButtonWithoutBackgroundScheme = MDCContainerScheme()
    public let blueFlatButtonWithoutBackgroundScheme = MDCContainerScheme()
    public let greenFlatButtonWithoutBackgroundScheme = MDCContainerScheme()
    
    public let defaultColorScheme: MDCSemanticColorScheme = {
        let scheme = MDCSemanticColorScheme(defaults: .material201804)
        scheme.primaryColor = #colorLiteral(red: 0.2474783659, green: 0.6575964093, blue: 0.2639612854, alpha: 1)
        scheme.onPrimaryColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        scheme.errorColor = #colorLiteral(red: 1, green: 0.2470588235, blue: 0.2666666667, alpha: 1)
        
        return scheme
    }()
    
    public let flatButtonWithoutBackgroundColorScheme: MDCSemanticColorScheme = {
        let scheme = MDCSemanticColorScheme(defaults: .material201804)
        scheme.primaryColor = #colorLiteral(red: 0.1219744459, green: 0.459923327, blue: 0.2891728282, alpha: 1)
        
        return scheme
    }()

    public let textfieldDefaultColorScheme: MDCSemanticColorScheme = {
        let scheme = MDCSemanticColorScheme(defaults: .material201804)
        scheme.primaryColor = #colorLiteral(red: 0.07236295193, green: 0.6188754439, blue: 0.2596520483, alpha: 1)
        scheme.onSurfaceColor = #colorLiteral(red: 0.7709081769, green: 0.7710202336, blue: 0.7708836794, alpha: 1)
        
        return scheme
    }()
    
    public let blueColorScheme: MDCSemanticColorScheme = {
        let scheme = MDCSemanticColorScheme(defaults: .material201804)
        scheme.primaryColor = #colorLiteral(red: 0, green: 0.3333333333, blue: 0.7215686275, alpha: 1)
        
        return scheme
    }()
    
    public let greenColorScheme: MDCSemanticColorScheme = {
        let scheme = MDCSemanticColorScheme(defaults: .material201804)
        scheme.primaryColor = #colorLiteral(red: 0.07236295193, green: 0.6188754439, blue: 0.2596520483, alpha: 1)
        
        return scheme
    }()
    
     public let grayColorScheme: MDCSemanticColorScheme = {
        let scheme = MDCSemanticColorScheme(defaults: .material201804)
        scheme.primaryColor = #colorLiteral(red: 0.6876367331, green: 0.6845007539, blue: 0.6877160072, alpha: 1)
        
        return scheme
    }()
    
    public let activityViewColorScheme: MDCSemanticColorScheme = {
        let scheme = MDCSemanticColorScheme(defaults: .material201804)
        scheme.primaryColor = #colorLiteral(red: 0.07236295193, green: 0.6188754439, blue: 0.2596520483, alpha: 1)
        scheme.secondaryColor = #colorLiteral(red: 0.568627451, green: 0.568627451, blue: 0.568627451, alpha: 1)
        
        return scheme
    }()
    
    public let defaultTypographyScheme: MDCTypographyScheme = {
        let scheme = MDCTypographyScheme()
        
        let lightFontName = "Muli-Light"
        let boldFontName = "Muli-Bold"
        let regularFontName = "Muli"
        
        scheme.headline6 = UIFont(name: regularFontName, size: 24)!
        scheme.headline5 = UIFont(name: lightFontName, size: 24)!
        scheme.headline4 = UIFont(name: boldFontName, size: 24)!
        scheme.headline3 = UIFont(name: regularFontName, size: 14)!
        scheme.subtitle1 = UIFont(name: lightFontName, size: 12)!
        scheme.subtitle2 = UIFont(name: regularFontName, size:16)!
        scheme.button = UIFont(name: lightFontName, size: 14)!
        scheme.subtitle2 = UIFont(name: lightFontName, size: 16)!
        
        return scheme
    }()
    
    public let labelsTypographyScheme: MDCTypographyScheme = {
        let scheme = MDCTypographyScheme()
        
        let lightFontName = "Muli-Light"
        let boldFontName = "Muli-Bold"
        let regularFontName = "Muli"
        
        scheme.headline1 = UIFont(name: lightFontName, size: 24)!
        scheme.subtitle1 = UIFont(name: regularFontName, size: 12)!
        scheme.subtitle2 = UIFont(name: regularFontName, size: 14)!
        
        return scheme
    }()
    
    public let textFieldTypographyScheme: MDCTypographyScheme = {
        let scheme = MDCTypographyScheme()
        
        let regularFontName = "Muli"
        
        scheme.headline1 = UIFont(name: regularFontName, size: 16)!
        scheme.subtitle1 = UIFont(name: regularFontName, size: 16)!
        scheme.subtitle2 = UIFont(name: regularFontName, size: 1)!
        
        return scheme
    }()
    
    public let boldTypographyScheme: MDCTypographyScheme = {
       let scheme = MDCTypographyScheme()
        
        let boldFontName = "Muli-Bold"
        scheme.button = UIFont(name: boldFontName, size: 16)!
        scheme.headline1 = UIFont(name: boldFontName, size: 17)!
        
        return scheme
    }()
    
    public let defaultShapeScheme: MDCShapeScheming = {
        let scheme = MDCShapeScheme()
        return scheme
    }()
}
