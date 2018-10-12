//
//  Insurance.swift
//  APIPackageDescription
//
//  Created by Omurok Chien on 2018/10/12.
//

import Vapor

class InsProcessor{
    var insName = ""
    var insSurName:[String] = []
    var insMoney:Int?
    var insCompany = ""
    var insTarget = ""
    var insNumber = ""
    var insType:Int = 0
    var insTypeSet:Bool = false
    var insStart:[String] = []
    var insLifeTime = ""
    var insEnd = ""
    var insPayDuration = ""
    var insPayInterval = ""
    var insPayPrice = ""
    var insFirstPay:[String] = []
    var insEndPay = ""
    
    func organizer(_ input:String)->String{
        startProcess(input)
        return "Return from InsProcessor Organizer \(input)"
    }
    
    
    func startOutput()->String{
        let dic : [String : Any] = ["insName":insName, "insSurName":insSurName,"insMoney":insMoney ?? 0,"insCompany":insCompany,"insTarget":insTarget,"insNumber":insNumber,"insType":insType,"insStart":insStart,"insLifeTime":insLifeTime,"insEnd":insEnd,"insPayDuration":insPayDuration,"insPayInterval":insPayInterval,"insPayPrice":insPayPrice,"insFirstPay":insFirstPay,"insEndPay":insEndPay]
        do{let data = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
            let jsonString = String(data: data, encoding: .utf8)
            return jsonString ?? "FAILED"
        }catch{
            return "ERROR"
        }
        
    }
    
    func startProcess(_ input:String){
        insName = ""
        insSurName = []
        insMoney = nil
        insCompany = ""
        insTarget = ""
        insNumber = ""
        insType = 0
        insTypeSet = false
        insStart = []
        insLifeTime = ""
        insEnd = ""
        insPayDuration = ""
        insPayInterval = ""
        insPayPrice = ""
        insFirstPay = []
        insEndPay = ""
        var data:[String] = []
        for str in input.components(separatedBy: "\n"){
            data.append(str)
        }
        print(data)
                    var done = false
                    for i in InsuranceCompany.allValues{
                        if input.contains(i.rawValue){
                            self.insuranceProcessor(company: i.rawValue, data: data)
                            done = true
                        }
                    }
                    if !done{
                        self.insuranceProcessor(company: "", data: data)
                    }
        
    }
    func insuranceProcessor(company:String,data:[String]){
        print("Insurance Processor into \(company)")
        let stringIndexMax = data.count - 1
        switch company {
        case InsuranceCompany.遠雄.rawValue:
            insCompany = "遠雄人壽"
            for i in 0...stringIndexMax{
                
                let source = data[i].replacingOccurrences(of: " ", with: "")
                if source.contains("被保險") && insTarget == ""{
                    insTarget = colonProcessor(source)
                }
                if insTarget != "" && source == insTarget{
                    if i+1 <= stringIndexMax{
                        insName = data[i+1]
                    }
                }
                if source.contains("附約") && source.count <= 25{
                    insSurName.append(source)
                }
                if source.contains("每期保險費") && insPayPrice == ""{
                    insPayPrice = String(moneyProcessor(source))
                }
            }
            
            
        case InsuranceCompany.全球.rawValue:
            insCompany = "全球人壽保險"
            for i in 0...stringIndexMax{
                let source = data[i].replacingOccurrences(of: " ", with: "")
                if source.contains("計劃單位") && insName == "" {
                    if i+1 <= stringIndexMax{
                        insName = data[i+1]
                    }
                }
                if source.contains("年") && source.contains("月") && source.contains("日") && insStart == []{
                    insStart = dateExtractor(source)
                    insFirstPay = insStart
                }
                if source.contains("應繳保險費") && insPayPrice == ""{
                    insPayPrice = String(moneyProcessor(source))
                }
            }
        case InsuranceCompany.富邦.rawValue:
            insCompany = "富邦人壽保險"
            for i in 0...stringIndexMax{
                let source = data[i].replacingOccurrences(of: " ", with: "")
                print(source)
                if source.contains("保險名稱") && insName == ""{
                    insName = colonProcessor(source)
                }
                if source.contains("保險金額") && insMoney == nil{
                    insMoney = (wanYuanProcessor(source))
                }
                if source.contains("保險期間") && insStart == []{
                    insStart = dateExtractor(source)
                    insFirstPay = insStart
                }
                if source.contains("主契約保險費") && insPayPrice == ""{
                    if i+1 <= stringIndexMax{
                        insPayPrice =  String(moneyProcessor(data[i+1]))
                    }
                }
                if source.contains("元整") && (insPayPrice == "" || insPayPrice == "0"){
                    insPayPrice = String(moneyProcessor(source))
                }
            }
        case InsuranceCompany.南山.rawValue:
            insCompany = "南山人壽保險"
            for i in 0...stringIndexMax{
                if data[i].contains("主契約") && insName == ""{
                    if i-1 <= stringIndexMax && i-1 >= 0{
                        insName = data[i-1]}}
                if  data[i].contains("0,000") && insMoney == nil{
                    insMoney = moneyProcessor(data[i])
                }
                if data[i] == "被保險人" && insTarget == ""{
                    if i+2 <= stringIndexMax {
                        insTarget = data[i+2]}}
                if data[i] == "保單號碼" && insNumber == ""{
                    if i+1 <= stringIndexMax {
                        insNumber = data[i+1]}}
                if data[i].contains("元整") && insPayPrice == ""{
                    if i-1 >= 0{
                        print("HERE",data[i-1])
                        insPayPrice =  String(moneyProcessor(String(data[i-1])))
                    }
                }
                
            }
        case InsuranceCompany.國寶.rawValue:
            insCompany = "國寶人壽保險"
            for i in 0...stringIndexMax{
                if data[i].contains("保單") && insNumber == ""{
                    insNumber = colonProcessor(data[i])
                }
                if data[i].contains("種類") && insName == ""{
                    insName = colonProcessor(data[i])
                }
                if data[i].contains("保險附"){
                    insSurName.append(colonProcessor(data[i]))
                }
                if data[i].contains("0,000") && insMoney == nil{
                    let paras = data[i].components(separatedBy: " ")
                    for para in paras{
                        if para.contains("0,000"){
                            insMoney = moneyProcessor(para)}
                    }
                }
                if (data[i].contains("被保險") || data[i].contains("被保险人")) && insTarget == ""{
                    if data[i].contains(":"){
                        if let result = data[i].components(separatedBy: ":").last{insTarget = result
                        }else if  data[i].contains("："){
                            if let result = data[i].components(separatedBy: "：").last{insTarget = result
                            }}else{insTarget = data[i]}}
                }
                
            }
        case InsuranceCompany.保誠.rawValue:
            insCompany = "保誠人壽保險"
            for i in 0...stringIndexMax{
                if data[i].contains("保險種類") && insName == ""{
                    insName = blankProcessor(data[i])
                }
                if data[i].contains("萬元"){
                    insMoney = wanYuanProcessor(data[i])
                }
                if data[i].contains("被保險") && data[i].count > 5 && insTarget == ""{
                    insTarget = stringRemover(input: data[i], toRemove: "被保險人")
                    
                }
                if data[i].contains("每期保險費") && insPayInterval == ""{
                    if data[i].contains("半年"){
                        insPayInterval = "半年"
                        
                    }else if data[i].contains("年"){
                        insPayInterval = "年"
                    }else if data[i].contains("季"){
                        insPayInterval = "季"
                    }else if data[i].contains("月"){
                        insPayInterval = "月"
                    }
                    insPayPrice = String(moneyProcessor(data[i]))
                }
                
                if data[i].contains("單號") && insNumber == ""{
                    insNumber = blankProcessor(data[i])
                }
                
            }
        case InsuranceCompany.中興.rawValue:
            insCompany = "中興人壽保險"
            for i in 0...stringIndexMax{
                if data[i] == "主契約" && insName == ""{
                    if i+1 <= stringIndexMax{
                        insName = data[i+1]}
                }
                if data[i] == "附加契約"{
                    if i+1 <= stringIndexMax{
                        insSurName.append(data[i+1])
                    }
                }
                if data[i].contains("契約期") && insStart == []{
                    insStart = dateExtractor(data[i])
                    insFirstPay = insStart
                }
                
                if data[i].contains("每期保險費") && insPayInterval == ""{
                    if data[i].contains("半年"){
                        insPayInterval = "半年"
                        
                    }else if data[i].contains("年"){
                        insPayInterval = "年"
                    }else if data[i].contains("季"){
                        insPayInterval = "季"
                    }else if data[i].contains("月"){
                        insPayInterval = "月"
                    }
                    insPayPrice = String(moneyProcessor(data[i]))
                }
            }
        case InsuranceCompany.幸福.rawValue:
            insCompany = "幸福人壽保險"
            for i in 0...stringIndexMax{
                if data[i].contains("種類") && insName == ""{
                    insName = colonProcessor(data[i])
                }
                if data[i].contains("新台幣")  && insPayPrice == ""{
                    print("data[i]",data[i])
                    let decoloned = colonProcessor(data[i])
                    //                    print("decoloned",decoloned)
                    let money = moneyProcessor(decoloned)
                    //                    print("money",money)
                    insPayPrice = String(money)
                    
                }
            }
        case InsuranceCompany.大都會.rawValue:
            insCompany = "大都會人壽保險"
            for i in 0...stringIndexMax{
                
                if data[i].contains("保險種類") && insName == ""{
                    insName = colonProcessor(data[i])
                }
                if data[i] == "主契約" && i+1 <= stringIndexMax && insName == ""{
                    insName = data[i+1]
                }
                
                if data[i].contains("被保險") && data[i].count > 5 && insTarget == ""{
                    if data[i].contains(":"){
                        insTarget = colonProcessor(data[i])
                    }
                }
                if data[i].contains("單號碼") && data[i].count > 5 && insNumber == ""{
                    if data[i].contains(":"){
                        insNumber = colonProcessor(data[i])
                    }
                }
                if data[i].contains("契約始期") && insStart == [] {
                    let paras = data[i].components(separatedBy: " ")
                    print("paras",paras)
                    var element:[Int] = []
                    for para in paras{
                        let trimmed = para.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
                        if let result = Int(trimmed){
                            element.append(result)
                        }
                    }
                    print(element)
                    insStart = dateExtractor(data[i])
                    insFirstPay = insStart
                }
                if data[i].contains("00,000") && insMoney == nil{
                    insMoney = moneyProcessor(data[i])
                    if i+2 <= stringIndexMax{
                        insPayPrice =  String(moneyProcessor(data[i+2]))
                    }
                }
                if data[i] == ("6") && insPayDuration == ""{insPayDuration = "6"}
                if data[i] == ("10") && insPayDuration == ""{insPayDuration = "10"}
                if data[i] == ("15") && insPayDuration == ""{insPayDuration = "15"}
                if data[i] == ("20") && insPayDuration == ""{insPayDuration = "20"}
                if data[i] == ("21") && insPayDuration == ""{insPayDuration = "21"}
                if data[i] == ("25") && insPayDuration == ""{insPayDuration = "25"}
                if data[i] == ("30") && insPayDuration == ""{insPayDuration = "30"}
            }
        default:
            print("into default")
            for i in 0...stringIndexMax{
                let source = data[i].replacingOccurrences(of: " ", with: "")
                if source.contains("種類") && insName == ""{
                    insName = colonProcessor(source)
                }
                if source.contains("被保險") && insTarget == ""{
                    if source.contains(":"){
                        if let result = source.components(separatedBy: ":").last{insTarget = result
                        }else if  source.contains("："){
                            if let result = source.components(separatedBy: "：").last{insTarget = result
                            }}else{insTarget = source}}
                }
                
                if source.contains("保險費") || insPayPrice == ""{
                    insPayPrice = source
                }
                
            }
        }
        for i in 0...stringIndexMax{
            let source = data[i].replacingOccurrences(of: " ", with: "")
            if source.contains("單號") && insNumber == ""{
                insNumber = colonProcessor(source)
            }
            if source.contains("被保險") && insTarget == ""{
                insTarget = colonProcessor(source)
            }
            if source.contains("公司") && insCompany == ""{
                insCompany = source
            }
            if source.contains("壽險") && insTypeSet == false{
                insType = 0
                insTypeSet = true
            }
            if source.contains("意外險") && insTypeSet == false{
                insType = 1
                insTypeSet = true
                
            }
            if (source.contains("儲蓄")||source.contains("投資")) && insTypeSet == false{
                insType = 2
                insTypeSet = true
            }
            if source.contains("防癌險") && insTypeSet == false{
                insType = 4
                insTypeSet = true
            }
            if source.contains("醫療險") && insTypeSet == false{
                insType = 3
            }
            if (source.contains("長照") || source.contains("殘扶") || source.contains("殘廢")) && insTypeSet == false{
                insType = 5
                insTypeSet = true
            }
            
            if source.contains("終身"){
                insLifeTime = "終身"
                insEnd = "無"
            }else if source.contains("定期"){
                insLifeTime = "定期"
            }
            if source.contains("6年") && insPayDuration == ""{insPayDuration = "6"}
            if source.contains("10年") && insPayDuration == ""{insPayDuration = "10"}
            if source.contains("15年") && insPayDuration == ""{insPayDuration = "15"}
            if source.contains("20年") && insPayDuration == ""{insPayDuration = "20"}
            if source.contains("21年") && insPayDuration == ""{insPayDuration = "21"}
            if source.contains("25年") && insPayDuration == ""{insPayDuration = "25"}
            if source.contains("30年") && insPayDuration == ""{insPayDuration = "30"}
            if source.contains("六年") && insPayDuration == ""{insPayDuration = "6"}
            if source.contains("十年") && insPayDuration == ""{insPayDuration = "10"}
            if source.contains("十五年") && insPayDuration == ""{insPayDuration = "15"}
            if source.contains("二十年") && insPayDuration == ""{insPayDuration = "20"}
            if source.contains("二十一年") && insPayDuration == ""{insPayDuration = "21"}
            if source.contains("二十五年") && insPayDuration == ""{insPayDuration = "25"}
            if source.contains("三十年") && insPayDuration == ""{insPayDuration = "30"}
            //            if source.contains("6") && insPayDuration == ""{insPayDuration = "6"}
            //            if source.contains("10") && insPayDuration == ""{insPayDuration = "10"}
            //            if source.contains("15") && insPayDuration == ""{insPayDuration = "15"}
            //            if source.contains("20") && insPayDuration == ""{insPayDuration = "20"}
            //            if source.contains("21") && insPayDuration == ""{insPayDuration = "21"}
            //            if source.contains("25") && insPayDuration == ""{insPayDuration = "25"}
            //            if source.contains("30") && insPayDuration == ""{insPayDuration = "30"}
            
            if (source.contains("半年繳") || source.contains("按半年")){
                insPayInterval = "半年繳"
                if insPayPrice == ""{
                    insPayPrice = String(moneyProcessor(source))}
            }
            if (source.contains("年繳") || source.contains("按年")){
                insPayInterval = "年繳"
                if insPayPrice == ""{
                    insPayPrice = String(moneyProcessor(source))}
            }
            if (source.contains("季繳") || source.contains("按季")){
                insPayInterval = "季繳"
                if insPayPrice == ""{
                    insPayPrice = String(moneyProcessor(source))}
            }
            if (source.contains("月繳") || source.contains("按月")){
                insPayInterval = "月繳"
                if insPayPrice == ""{
                    insPayPrice = String(moneyProcessor(source))}
            }
            if (source.contains("躉繳") || source.contains("臺繳")) || source.contains("蔓繳"){
                insPayInterval = "躉繳"
            }
            
            if source.contains("00,000") && insMoney == nil{
                insMoney = moneyProcessor(source)
            }
            if source.contains("契約始期") && insStart == [] {
                insStart = dateExtractor(source)
                insFirstPay = insStart
                
                
            }
            if (source.contains("契約終期") || source.contains("契約滿期")) && insEnd == "" {
                insLifeTime = "非終身"
                insEnd = colonProcessor(source)
                insEndPay = colonProcessor(source)
            }
        }
        self.startOutput()
    }
    
    func taiwanYearProcessor(_ input:String) -> Date?{
        return Date()
    }
    
    
    func colonProcessor(_ input:String) -> String{
        var output = ""
        if input.contains(":"){
            if let result = input.components(separatedBy: ":").last{output = result
            }else if  input.contains("："){
                if let result = input.components(separatedBy: "：").last{output = result
                }}else{output = input}}else{
            output = input
        }
        return output
    }
    func moneyProcessor(_ input:String) -> Int{
        var result:Int = 0
        let output = input.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
        if let money = Int(output){
            result = money
        }
        return result
    }
    func blankProcessor(_ input:String) -> String{
        var output = ""
        if input.contains(" "){
            if let result = input.components(separatedBy: " ").last{
                output = result
            }else{
                output = input
            }
        }else{
            output = input
        }
        return output
    }
    func wanYuanProcessor(_ input:String) -> Int{
        if input.contains("萬"){
            var numberic = moneyProcessor(input)
            numberic = numberic * 10000
            return numberic
        }else{
            let numberic = moneyProcessor(input)
            return numberic
        }
    }
    func stringRemover(input:String, toRemove:String) -> String{
        var output = ""
        if input.contains(toRemove){
            if let result = input.components(separatedBy: toRemove).last{
                output = result
            }else{
                output = input
            }
        }else{
            output = input
        }
        return output
    }
    func dateExtractor(_ input:String) -> [String]{
        print("Into dateExtractor")
        print("USE STRING",input)
        if input.contains("年"){
            print("contains年月日")
            var components:[String] = []
            if let year = input.components(separatedBy: "年").first,let rest = input.components(separatedBy: "年").last{
                components.append(year)
                if let month = rest.components(separatedBy: "月").first,let rest2 = rest.components(separatedBy: "月").last{
                    components.append(month)
                    if let day = rest2.components(separatedBy: "日").first{
                        components.append(day)
                    }
                }
            }
            print("components",components)
            let paras = input.components(separatedBy: "年")
            print("paras=",paras)
            var element:[Int] = []
            for para in components{
                let trimmed = para.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
                if let result = Int(trimmed){
                    element.append(result)
                }
            }
            print("paras processed",paras)
            var elementInString:[String] = []
            for i in element{
                if i < 10{
                    let i0 = "0" + String(i)
                    elementInString.append(i0)
                }else{
                    elementInString.append(String(i))
                }
            }
            if let elementYear = elementInString.first{
                if let yearInInt = Int(elementYear){
                    if yearInInt < 1000{
                        let wYear = yearInInt + 1911
                        elementInString.remove(at: 0)
                        elementInString.insert(String(wYear), at: 0)
                    }
                }
            }
            print("elementInString",elementInString)
            return elementInString
            
        }else{
            print("NO 年月日")
            var trimmed = input.components(separatedBy: CharacterSet.decimalDigits.inverted)
            trimmed = trimmed.filter { $0 != ""}
            return trimmed
        }
    }
    
    func arrayToDate(_ input:[String]) -> Date?{
        if input.count == 3{
            if let year = Int(input[0]), let month = Int(input[1]) ,let day = Int(input[2]){
                var yearPro = year
                if yearPro < 200 {yearPro += 1911}
                let cal = Calendar(identifier: .gregorian)
                let component = DateComponents(calendar: cal, timeZone: nil, era: nil, year: yearPro, month: month, day: day, hour: nil, minute: nil, second: nil, nanosecond: nil, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
                if let date = component.date{
                    return date
                }else{
                    return nil
                }
            }else{
                return nil
            }
        }else{
            return nil
        }
    }
    func dateEndCalculator(_ startDate:Date?,durationInYear:Int) -> Date?{
        let cal = Calendar(identifier: .gregorian)
        
        if let start = startDate{
            let year = cal.component(.year, from: start)
            let month = cal.component(.month, from: start)
            let day = cal.component(.day, from: start)
            let endYear = year+durationInYear
            let endComp = DateComponents(calendar: cal, timeZone: nil, era: nil, year: endYear, month: month, day: day, hour: nil, minute: nil, second: nil, nanosecond: nil, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
            if let end = endComp.date{
                
                return end
            }else{
                print("endComp to Date failed")
                return nil
            }
            
        }else{
            print("NO STARTDATE")
            return nil
        }
    }
    
}

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


public struct InsOriginalInfo: Content {
    var text: String
}
enum InsuranceCompany:String {
    
    case 幸福 = "幸福"
    case 大都會 = "大都會"
    case 遠雄 = "遠雄"
    case 富邦 = "富邦"
    case 全球 = "全球"
    case 中興 = "中興"
    case 保誠 = "保誠"
    case 國寶 = "國寶"
    case 南山 = "南山"
    
    static let allValues = [幸福,大都會,遠雄,富邦,全球,中興,保誠,國寶,南山]
}
