//
//  huge_numbersTests.swift
//
//
//  Created by Evan Anderson on 4/10/23.
//

import XCTest
import HugeNumbers

final class huge_numbersTests : XCTestCase {
    func testExample() async throws {
        //try await test_benchmarks()
        
        test_hugeint2()
        
        return;
        test_sin()
        test_pi()
    }
    
    func test_hugeint2() {
        var integer:HugeInt2 = HugeInt2(UInt64.max) + HugeInt2(3)
        
        var target_binary:[Bool] = [Bool].init(repeating: false, count: 64)
        target_binary.insert(true, at: 0)
        target_binary[63] = true
        
        var result:HugeInt2 = HugeInt2(binary: target_binary)
        
        XCTAssertEqual(integer, result, integer.binary_string + " != " + result.binary_string)
        
        integer = HugeInt2(4) - HugeInt2(1)
        result = HugeInt2(3)
        XCTAssertEqual(integer, result, integer.binary_string + " != " + result.binary_string)
        
        integer = HugeInt2(15) - HugeInt2(1)
        result = HugeInt2(14)
        XCTAssertEqual(integer, result, integer.binary_string + " != " + result.binary_string)
        
        integer = HugeInt2(15) - HugeInt2(7)
        result = HugeInt2(8)
        XCTAssertEqual(integer, result, integer.binary_string + " != " + result.binary_string)
        
        let test:[Int8] = HugeInt2.get_bit_value(bit_width: 128)
        print("test=" + test.debugDescription)
    }
}

extension huge_numbersTests {
    private func test_benchmarks() async throws {
        guard #available(macOS 13.0, iOS 16.0, *) else { return }
        
        /*let dividend:HugeInt = HugeInt("41"), divisor:HugeInt = HugeInt("4")
        try await benchmark_compare_is_faster(key1: "HugeInt.divide1", {
            let _ = HugeInt.divide(dividend: dividend, divisor: divisor)
        }, key2: "HugeInt.divide2", code2: {
            let _ = HugeInt.divide2(dividend: dividend, divisor: divisor)
        })*/
        
        for _ in 1...5 {
            try await test()
            //try await test_benchmark_integer_addition()
            //try await test_benchmark_integer_subtraction()
            //try await test_benchmark_integer_multiplication()
            //try await test_benchmark_integer_division()
            
            //try await test_benchmark_float_addition()
            //try await test_benchmark_float_subtraction()
            //try await test_benchmark_float_multiplication()
            //try await test_benchmark_float_division()
        }
    }
    @available(macOS 13.0, *)
    private func test() async throws {
        /*let remainder:HugeRemainder = HugeRemainder(dividend: "12355", divisor: "87315")
        try await benchmark_compare_is_faster(maximum_iterations: 10, key1: "HugeRemainder.to_decimal", {
            let _:HugeDecimal = remainder.to_decimal()
        }, key2: "HugeRemainder.to_decimal2") {
            let _:HugeDecimal = remainder.to_decimal2()
        }*/
    }
    
    @available(macOS 13.0, *)
    private func test_benchmark_integer_addition() async throws {
        let left_native:UInt64 = 8237502387529357, right_native:UInt64 = 397653549738
        let left:HugeInt = HugeInt(left_native), right:HugeInt = HugeInt(right_native)
        try await benchmark_compare_is_faster(key1: "HugeInt.add", {
            let _:HugeInt = left + right
        }, key2: "UInt64.add", code2: {
            let _:UInt64 = left_native.addingReportingOverflow(right_native).partialValue
        })
    }
    @available(macOS 13.0, *)
    private func test_benchmark_integer_subtraction() async throws {
        let left_native:UInt64 = 8237502387529357, right_native:UInt64 = 397653549738
        let left:HugeInt = HugeInt(left_native), right:HugeInt = HugeInt(right_native)
        try await benchmark_compare_is_faster(key1: "HugeInt.subtract", {
            let _:HugeInt = left - right
        }, key2: "UInt64.add", code2: {
            let _:UInt64 = left_native.subtractingReportingOverflow(right_native).partialValue
        })
    }
    @available(macOS 13.0, *)
    private func test_benchmark_integer_multiplication() async throws {
        let left_native:UInt64 = 8237502387529357, right_native:UInt64 = 397653549738
        let left:HugeInt = HugeInt(left_native), right:HugeInt = HugeInt(right_native)
        try await benchmark_compare_is_faster(key1: "HugeInt.multiply", {
            let _:HugeInt = left * right
        }, key2: "UInt64.multiply", code2: {
            let _:UInt64 = left_native.multipliedReportingOverflow(by: right_native).partialValue
        })
    }
    @available(macOS 13.0, *)
    private func test_benchmark_integer_division() async throws {
        let left_native:UInt64 = 8237502387529357, right_native:UInt64 = 397653549738
        let left:HugeInt = HugeInt(left_native), right:HugeInt = HugeInt(right_native)
        try await benchmark_compare_is_faster(key1: "HugeInt.divide", {
            let (_, _):(HugeInt, HugeRemainder?) = left / right
        }, key2: "UInt64.divide", code2: {
            let _:UInt64 = left_native.dividedReportingOverflow(by: right_native).partialValue
        })
    }
    
    @available(macOS 13.0, *)
    private func test_benchmark_float_addition() async throws {
        let left_native:Float = 12345.678, right_native:Float = 54321.012
        let left:HugeFloat = HugeFloat("12345.678"), right:HugeFloat = HugeFloat("54321.012")
        try await benchmark_compare_is_faster(key1: "HugeFloat.add", {
            let _:HugeFloat = left + right
        }, key2: "Float.add", code2: {
            let _:Float = left_native + right_native
        })
    }
    @available(macOS 13.0, *)
    private func test_benchmark_float_subtraction() async throws {
        let left_native:Float = 12345.678, right_native:Float = 54321.012
        let left:HugeFloat = HugeFloat("12345.678"), right:HugeFloat = HugeFloat("54321.012")
        try await benchmark_compare_is_faster(key1: "HugeFloat.subtract", {
            let _:HugeFloat = left - right
        }, key2: "Float.subtract", code2: {
            let _:Float = left_native - right_native
        })
    }
    @available(macOS 13.0, *)
    private func test_benchmark_float_multiplication() async throws {
        let left_native:Float = 12345.678, right_native:Float = 54321.012
        let left:HugeFloat = HugeFloat("12345.678"), right:HugeFloat = HugeFloat("54321.012")
        try await benchmark_compare_is_faster(key1: "HugeFloat.multiply", {
            let _:HugeFloat = left * right
        }, key2: "Float.multiply", code2: {
            let _:Float = left_native * right_native
        })
    }
    @available(macOS 13.0, *)
    private func test_benchmark_float_division() async throws {
        let left_native:Float = 12345.678, right_native:Float = 54321.012
        let left:HugeFloat = HugeFloat("12345.678"), right:HugeFloat = HugeFloat("54321.012")
        let precision:HugeInt = HugeInt.default_precision
        try await benchmark_compare_is_faster(key1: "HugeFloat.divide", {
            let _:HugeFloat = left.divide_by(right, precision: precision)
        }, key2: "Float.divide", code2: {
            let _:Float = left_native / right_native
        })
    }
}

extension huge_numbersTests {
    @available(macOS 13.0, iOS 16.0, watchOS 9.0, *)
    private func benchmark(iteration_count: Int = 10_00, key: String, _ code: @escaping () async throws -> Void, will_print: Bool = true) async throws -> (key: String, min: Int64, max: Int64, median: Int64, average: Int64, total: Int64) {
        let clock:SuspendingClock = SuspendingClock()
        let _:Duration = try await clock.measure(code)
        var timings:[Int64] = [Int64].init(repeating: 0, count: iteration_count)
        for i in 0..<iteration_count {
            let result:Duration = try await clock.measure(code)
            let attoseconds:Int64 = result.components.attoseconds
            let nanoseconds:Int64 = attoseconds / 1_000_000_000
            timings[i] = nanoseconds
        }
        timings = timings.sorted(by: { $0 < $1 })
        let minimum:Int64 = timings[0], maximum:Int64 = timings[iteration_count-1]
        let median:Int64 = timings[iteration_count/2]
        let sum:Int64 = timings.reduce(0, +)
        let average:Int64 = Int64( Double(sum) / Double(iteration_count) )
        if will_print {
            let key:String = key + (1...(80-key.count)).map({ _ in " " }).joined()
            
            let formatter:NumberFormatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 20
            
            let average_time_elapsed:String = get_benchmark_formatted_string(formatter: formatter, average)
            let minimum_time_elapsed:String = get_benchmark_formatted_string(formatter: formatter, minimum)
            let maximum_time_elapsed:String = get_benchmark_formatted_string(formatter: formatter, maximum)
            let median_time_elapsed:String = get_benchmark_formatted_string(formatter: formatter, median)
            let total_time_elapsed:String = get_benchmark_formatted_string(formatter: formatter, sum)
            
            print("huge_numbersTests;benchmark( " + key + "| min=" + minimum_time_elapsed + " | max=" + maximum_time_elapsed + " | median=" + median_time_elapsed + " | average=" + average_time_elapsed + " | total=" + total_time_elapsed)
        }
        return (key: key, min: minimum, max: maximum, median: median, average: average, total: sum)
    }
    private func benchmark_compare_is_faster(maximum_iterations: Int = 100, key1: String, _ code1: @escaping () async throws -> Void, key2: String, code2: @escaping () async throws -> Void) async throws {
        guard #available(macOS 13.0, iOS 16.0, watchOS 9.0, *) else {
            print("huge_numbersTests;benchmark_compare_is_faster; unsupported platform version")
            return
        }
        var faster_count:Int = 0, faster_average:Int64 = 0
        for _ in 1...maximum_iterations {
            let faster:(Bool, Int64) = try await benchmark_compare(key1: key1, code1, key2: key2, code2: code2, print_to_console: false)
            faster_count += faster.0 ? 1 : 0
            faster_average += faster.1
        }
        let formatter:NumberFormatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 20
        let average_string:String = get_benchmark_formatted_string(formatter: formatter, faster_average / Int64(maximum_iterations))
        print("huge_numbersTests;benchmark_compare_is_faster;     " + key1 + " is faster \(faster_count)/\(maximum_iterations) on average by " + average_string)
    }
    @available(macOS 13.0, iOS 16.0, watchOS 9.0, *)
    private func benchmark_compare(key1: String, _ code1: @escaping () async throws -> Void, key2: String, code2: @escaping () async throws -> Void, print_to_console: Bool = true) async throws -> (Bool, Int64) {
        async let test1 = benchmark(key: key1, code1, will_print: false)
        async let test2 = benchmark(key: key2, code2, will_print: false)
        let ((key1, min1, max1, median1, average1, total1) , (_, min2, max2, median2, average2, total2)) = try await (test1, test2)
        
        if print_to_console {
            let formatter:NumberFormatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 20
            
            let average_time_diff:String = get_benchmark_formatted_string(formatter: formatter, max(average1, average2) - min(average1, average2))
            let minimum_time_diff:String = get_benchmark_formatted_string(formatter: formatter, max(min1, min2) - min(min1, min2))
            let maximum_time_diff:String = get_benchmark_formatted_string(formatter: formatter, max(max1, max2) - min(max1, max2))
            let median_time_diff:String = get_benchmark_formatted_string(formatter: formatter, max(median1, median2) - min(median1, median2))
            let total_time_diff:String = get_benchmark_formatted_string(formatter: formatter, max(total1, total2) - min(total1, total2), separation_count: 20)
            
            let key:String = key1 + (1...(70-key1.count)).map({ _ in " " }).joined()
            var string:String = "huge_numbersTests;benchmark_compare( " + key + "| "
            string.append("min=" + (min1 < min2 ? "🟢" : "🔴") + "by " + minimum_time_diff)
            string.append(" | max=" + (max1 < max2 ? "🟢" : "🔴") + "by " + maximum_time_diff)
            string.append(" | median=" + (median1 < median2 ? "🟢" : "🔴") + "by " + median_time_diff)
            string.append(" | average=" + (average1 < average2 ? "🟢" : "🔴") + "by " + average_time_diff)
            string.append(" | total=" + (total1 < total2 ? "🟢" : "🔴") + "by " + total_time_diff)
            print(string)
        }
        return (average1 <= average2, average2 - average1)
    }
    private func get_benchmark_formatted_string(formatter: NumberFormatter, _ value: Any, separation_count: Int = 20) -> String {
        let string:String = formatter.string(for: value)! + "ns"
        return string + (0..<(separation_count - (string.count))).map({ _ in " " }).joined()
    }
}

extension huge_numbersTests {
    private func test_sin() {
        /*var (value, decimal):(HugeInt?, HugeDecimal?) = sin(HugeFloat("90"), precision: HugeInt.default_precision)
        var (expected_value, expected_decimal):(HugeInt?, HugeDecimal?) = (HugeInt("1"), nil)
        XCTAssert(value == expected_value && decimal == expected_decimal, "test_sin;value=\(value);decimal=\(decimal);expected_value=\(expected_value);expected_decimal=\(expected_decimal)")*/
    }
}

extension huge_numbersTests {
    private func test_pi() {
        return
        // the first 32 characters contain at least 1 of every digit (0-9)
        let pi_100:String = "1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679"
        let pi_1_000:String = "1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679821480865132823066470938446095505822317253594081284811174502841027019385211055596446229489549303819644288109756659334461284756482337867831652712019091456485669234603486104543266482133936072602491412737245870066063155881748815209209628292540917153643678925903600113305305488204665213841469519415116094330572703657595919530921861173819326117931051185480744623799627495673518857527248912279381830119491298336733624406566430860213949463952247371907021798609437027705392171762931767523846748184676694051320005681271452635608277857713427577896091736371787214684409012249534301465495853710507922796892589235420199561121290219608640344181598136297747713099605187072113499999983729780499510597317328160963185950244594553469083026425223082533446850352619311881710100031378387528865875332083814206171776691473035982534904287554687311595628638823537875937519577818577805321712268066130019278766111959092164201989"
        let pi_10_000:String = "1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679821480865132823066470938446095505822317253594081284811174502841027019385211055596446229489549303819644288109756659334461284756482337867831652712019091456485669234603486104543266482133936072602491412737245870066063155881748815209209628292540917153643678925903600113305305488204665213841469519415116094330572703657595919530921861173819326117931051185480744623799627495673518857527248912279381830119491298336733624406566430860213949463952247371907021798609437027705392171762931767523846748184676694051320005681271452635608277857713427577896091736371787214684409012249534301465495853710507922796892589235420199561121290219608640344181598136297747713099605187072113499999983729780499510597317328160963185950244594553469083026425223082533446850352619311881710100031378387528865875332083814206171776691473035982534904287554687311595628638823537875937519577818577805321712268066130019278766111959092164201989380952572010654858632788659361533818279682303019520353018529689957736225994138912497217752834791315155748572424541506959508295331168617278558890750983817546374649393192550604009277016711390098488240128583616035637076601047101819429555961989467678374494482553797747268471040475346462080466842590694912933136770289891521047521620569660240580381501935112533824300355876402474964732639141992726042699227967823547816360093417216412199245863150302861829745557067498385054945885869269956909272107975093029553211653449872027559602364806654991198818347977535663698074265425278625518184175746728909777727938000816470600161452491921732172147723501414419735685481613611573525521334757418494684385233239073941433345477624168625189835694855620992192221842725502542568876717904946016534668049886272327917860857843838279679766814541009538837863609506800642251252051173929848960841284886269456042419652850222106611863067442786220391949450471237137869609563643719172874677646575739624138908658326459958133904780275900994657640789512694683983525957098258226205224894077267194782684826014769909026401363944374553050682034962524517493996514314298091906592509372216964615157098583874105978859597729754989301617539284681382686838689427741559918559252459539594310499725246808459872736446958486538367362226260991246080512438843904512441365497627807977156914359977001296160894416948685558484063534220722258284886481584560285060168427394522674676788952521385225499546667278239864565961163548862305774564980355936345681743241125150760694794510965960940252288797108931456691368672287489405601015033086179286809208747609178249385890097149096759852613655497818931297848216829989487226588048575640142704775551323796414515237462343645428584447952658678210511413547357395231134271661021359695362314429524849371871101457654035902799344037420073105785390621983874478084784896833214457138687519435064302184531910484810053706146806749192781911979399520614196634287544406437451237181921799983910159195618146751426912397489409071864942319615679452080951465502252316038819301420937621378559566389377870830390697920773467221825625996615014215030680384477345492026054146659252014974428507325186660021324340881907104863317346496514539057962685610055081066587969981635747363840525714591028970641401109712062804390397595156771577004203378699360072305587631763594218731251471205329281918261861258673215791984148488291644706095752706957220917567116722910981690915280173506712748583222871835209353965725121083579151369882091444210067510334671103141267111369908658516398315019701651511685171437657618351556508849099898599823873455283316355076479185358932261854896321329330898570642046752590709154814165498594616371802709819943099244889575712828905923233260972997120844335732654893823911932597463667305836041428138830320382490375898524374417029132765618093773444030707469211201913020330380197621101100449293215160842444859637669838952286847831235526582131449576857262433441893039686426243410773226978028073189154411010446823252716201052652272111660396665573092547110557853763466820653109896526918620564769312570586356620185581007293606598764861179104533488503461136576867532494416680396265797877185560845529654126654085306143444318586769751456614068007002378776591344017127494704205622305389945613140711270004078547332699390814546646458807972708266830634328587856983052358089330657574067954571637752542021149557615814002501262285941302164715509792592309907965473761255176567513575178296664547791745011299614890304639947132962107340437518957359614589019389713111790429782856475032031986915140287080859904801094121472213179476477726224142548545403321571853061422881375850430633217518297986622371721591607716692547487389866549494501146540628433663937900397692656721463853067360965712091807638327166416274888800786925602902284721040317211860820419000422966171196377921337575114959501566049631862947265473642523081770367515906735023507283540567040386743513622224771589150495309844489333096340878076932599397805419341447377441842631298608099888687413260472156951623965864573021631598193195167353812974167729478672422924654366800980676928238280689964004824354037014163149658979409243237896907069779422362508221688957383798623001593776471651228935786015881617557829735233446042815126272037343146531977774160319906655418763979293344195215413418994854447345673831624993419131814809277771038638773431772075456545322077709212019051660962804909263601975988281613323166636528619326686336062735676303544776280350450777235547105859548702790814356240145171806246436267945612753181340783303362542327839449753824372058353114771199260638133467768796959703098339130771098704085913374641442822772634659470474587847787201927715280731767907707157213444730605700733492436931138350493163128404251219256517980694113528013147013047816437885185290928545201165839341965621349143415956258658655705526904965209858033850722426482939728584783163057777560688876446248246857926039535277348030480290058760758251047470916439613626760449256274204208320856611906254543372131535958450687724602901618766795240616342522577195429162991930645537799140373404328752628889639958794757291746426357455254079091451357111369410911939325191076020825202618798531887705842972591677813149699009019211697173727847684726860849003377024242916513005005168323364350389517029893922334517220138128069650117844087451960121228599371623130171144484640903890644954440061986907548516026327505298349187407866808818338510228334508504860825039302133219715518430635455007668282949304137765527939751754613953984683393638304746119966538581538420568533862186725233402830871123282789212507712629463229563989898935821167456270102183564622013496715188190973038119800497340723961036854066431939509790190699639552453005450580685501956730229219139339185680344903982059551002263535361920419947455385938102343955449597783779023742161727111723643435439478221818528624085140066604433258885698670543154706965747458550332323342107301545940516553790686627333799585115625784322988273723198987571415957811196358330059408730681216028764962867446047746491599505497374256269010490377819868359381465741268049256487985561453723478673303904688383436346553794986419270563872931748723320837601123029911367938627089438799362016295154133714248928307220126901475466847653576164773794675200490757155527819653621323926406160136358155907422020203187277605277219005561484255518792530343513984425322341576233610642506390497500865627109535919465897514131034822769306247435363256916078154781811528436679570611086153315044521274739245449454236828860613408414863776700961207151249140430272538607648236341433462351897576645216413767969031495019108575984423919862916421939949072362346468441173940326591840443780513338945257423995082965912285085558215725031071257012668302402929525220118726767562204154205161841634847565169998116141010029960783869092916030288400269104140792886215078424516709087000699282120660418371806535567252532567532861291042487761825829765157959847035622262934860034158722980534989650226291748788202734209222245339856264766914905562842503912757710284027998066365825488926488025456610172967026640765590429099456815065265305371829412703369313785178609040708667114965583434347693385781711386455873678123014587687126603489139095620099393610310291616152881384379099042317473363948045759314931405297634757481193567091101377517210080315590248530906692037671922033229094334676851422144773793937517034436619910403375111735471918550464490263655128162288244625759163330391072253837421821408835086573917715096828874782656995995744906617583441375223970968340800535598491754173818839994469748676265516582765848358845314277568790029095170283529716344562129640435231176006651012412006597558512761785838292041974844236080071930457618932349229279650198751872127267507981255470958904556357921221033346697499235630254947802490114195212382815309114079073860251522742995818072471625916685451333123948049470791191532673430282441860414263639548000448002670496248201792896476697583183271314251702969234889627668440323260927524960357996469256504936818360900323809293459588970695365349406034021665443755890045632882250545255640564482465151875471196218443965825337543885690941130315095261793780029741207665147939425902989695946995565761218656196733786236256125216320862869222103274889218654364802296780705765615144632046927906821207388377814233562823608963208068222468012248261177185896381409183903673672220888321513755600372798394004152970028783076670944474560134556417254370906979396122571429894671543578468788614445812314593571984922528471605049221242470141214780573455105008019086996033027634787081081754501193071412233908663938339529425786905076431006383519834389341596131854347546495569781038293097164651438407007073604112373599843452251610507027056235266012764848308407611830130527932054274628654036036745328651057065874882256981579367897669742205750596834408697350201410206723585020072452256326513410559240190274216248439140359989535394590944070469120914093870012645600162374288021092764579310657922955249887275846101264836999892256959688159205600101655256375678"
        if #available(macOS 13.0, *) {
            for i in 0...9 {
                test_pi_indexes(i: i, pi_100, bigger_digits: pi_1_000)
                test_pi_ranges(i: i, pi_100)
                test_pi_ranges(i: i, pi_1_000)
                test_pi_ranges(i: i, pi_10_000)
                print("")
            }
        }
        /*
        let precision:HugeInt = HugeInt("5")
        let pi:HugeFloat = HugeFloat.pi(precision: precision)
        print("test_pi;pi=" + pi.description + ";precision=" + precision.description)*/
    }
    private func test_pi_indexes(i: Int, _ pi_digits: String, bigger_digits: String) {
        if #available(macOS 13.0, iOS 16.0, watchOS 9.0, *) {
            let ranges:[Range<String.Index>] = pi_digits.ranges(of: String(describing: i))
            var range_index:Int = 0
            for range in ranges {
                print("test_pi_indexes;i=" + i.description + ";range_index=\(pi_digits.distance(from: pi_digits.startIndex, to: range.lowerBound))")
                range_index += 1
            }
            let last_index:String.Index = pi_digits.index(before: ranges.last!.lowerBound), next_index:String.Index = pi_digits.index(after: ranges.last!.lowerBound)
            print("test_pi_indexes;i=" + i.description + ";previous number=" + pi_digits[last_index].description + ";next_number=" + bigger_digits[next_index].description)
        }
    }
    private func test_pi_ranges(i: Int, _ pi_digits: String) {
        if #available(macOS 13.0, iOS 16.0, watchOS 9.0, *) {
            let string_count:Int = pi_digits.count
            let ranges:[Range<String.Index>] = pi_digits.ranges(of: String(describing: i))
            var minimum_distance_between:Int = string_count, maximum_distance_between:Int = 0
            var range_index:Int = 0
            let ranges_count:Int = ranges.count
            for range in ranges {
                if range_index+1 < ranges_count {
                    let next_range:String.Index = pi_digits.index(after: ranges[range_index+1].lowerBound)
                    let distance:Int = pi_digits.distance(from: range.lowerBound, to: next_range)
                    if distance < minimum_distance_between {
                        minimum_distance_between = distance
                    }
                    if distance > maximum_distance_between {
                        maximum_distance_between = distance
                    }
                }
                range_index += 1
            }
            print("test_pi_ranges;i=\(i);\(string_count);ranges.count=\(ranges_count);minimum_distance_between=\(minimum_distance_between);maximum_distance_between=\(maximum_distance_between)")
        }
    }
}
