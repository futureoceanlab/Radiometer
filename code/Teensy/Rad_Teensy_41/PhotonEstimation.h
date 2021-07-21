#include <math.h>
#include <stdint-gcc.h>

#define ESTCUTOFF_LIN 1
#define ESTCUTOFF_LOW 20
#define ESTCUTOFF_HIGH 70

#define INVLUTSTEP 10
#define LUTSTEP 0.1F
#define LUTOFFSET_LOW 5
#define LUTOFFSET_HIGH 0

const float invLUT_lowPulses[2][91] {
{   148745.F,    158781.F,    168817.F,    178854.F,    188890.F,    198926.F,    208963.F,    218999.F,    229035.F,    239072.F,
    249106.F,    259033.F,    268796.F,    278412.F,    287897.F,    297261.F,    306516.F,    315672.F,    324738.F,    333721.F,
    342629.F,    351468.F,    360244.F,    368963.F,    377630.F,    386250.F,    394826.F,    403364.F,    411867.F,    420338.F,
    428781.F,    437200.F,    445597.F,    453975.F,    462337.F,    470685.F,    479023.F,    487352.F,    495675.F,    503994.F,
    512311.F,    520628.F,    528944.F,    537260.F,    545576.F,    553892.F,    562208.F,    570524.F,    578840.F,    587157.F,
    595474.F,    603792.F,    612111.F,    620430.F,    628750.F,    637071.F,    645392.F,    653714.F,    662036.F,    670360.F,
    678685.F,    687013.F,    695345.F,    703682.F,    712026.F,    720377.F,    728737.F,    737107.F,    745487.F,    753880.F,
    762286.F,    770707.F,    779143.F,    787595.F,    796064.F,    804553.F,    813061.F,    821590.F,    830139.F,    838710.F,
    847299.F,    855905.F,    864527.F,    873163.F,    881812.F,    890472.F,    899141.F,    907819.F,    916502.F,    925191.F,
    933883.F},
{   933883.F,   1020687.F,   1107210.F,   1194453.F,   1282740.F,   1371565.F,   1460527.F,   1549400.F,   1638393.F,   1728079.F,
   1819060.F,   1911913.F,   2006902.F,   2104051.F,   2202954.F,   2303054.F,   2403780.F,   2504587.F,   2604973.F,   2704682.F,
   2804366.F,   2903894.F,   3002826.F,   3100779.F,   3197432.F,   3292754.F,   3387404.F,   3482100.F,   3577520.F,   3674196.F,
   3772263.F,   3871765.F,   3972760.F,   4075319.F,   4179486.F,   4285345.F,   4392944.F,   4502352.F,   4613509.F,   4726218.F,
   4840278.F,   4955474.F,   5071580.F,   5188364.F,   5305738.F,   5423922.F,   5543039.F,   5663171.F,   5784415.F,   5906839.F,
   6030556.F,   6155637.F,   6282209.F,   6410348.F,   6540182.F,   6671825.F,   6805387.F,   6941015.F,   7078854.F,   7218971.F,
   7361360.F,   7506024.F,   7653029.F,   7802537.F,   7954741.F,   8109854.F,   8268129.F,   8429821.F,   8595198.F,   8764572.F,
   8938244.F,   9116491.F,   9299475.F,   9487432.F,   9680710.F,   9879499.F,  10084145.F,  10295086.F,  10513048.F,  10738920.F,
  10973849.F,  11219066.F,  11476212.F,  11747216.F,  12034385.F,  12340679.F,  12670296.F,  13028720.F,  13424325.F,  13869992.F,
  14389117.F}
};

const float invLUT_hiPulses[7][91] {
    {188094838.F, 187053783.F, 186113741.F, 185259246.F, 184476676.F, 183754076.F, 183080983.F, 182448273.F, 181868570.F, 181318757.F,
    180790224.F, 180307084.F, 179836444.F, 179395467.F, 178970725.F, 178568280.F, 178179078.F, 177811837.F, 177449267.F, 177114183.F,
    176779099.F, 176464906.F, 176159188.F, 175854973.F, 175576066.F, 175297158.F, 175022139.F, 174767704.F, 174513270.F, 174258835.F,
    174026682.F, 173794583.F, 173562483.F, 173341552.F, 173129832.F, 172918112.F, 172706392.F, 172509245.F, 172316117.F, 172122989.F,
    171929862.F, 171748201.F, 171572032.F, 171395864.F, 171219695.F, 171046523.F, 170885822.F, 170725120.F, 170564419.F, 170403717.F,
    170247282.F, 170100685.F, 169954088.F, 169807491.F, 169660894.F, 169514297.F, 169380114.F, 169246377.F, 169112641.F, 168978904.F,
    168845167.F, 168713093.F, 168591081.F, 168469069.F, 168347057.F, 168225045.F, 168103033.F, 167981021.F, 167867430.F, 167756106.F,
    167644783.F, 167533459.F, 167422135.F, 167310812.F, 167199488.F, 167096504.F, 166994924.F, 166893343.F, 166791762.F, 166690181.F,
    166588600.F, 166487020.F, 166388051.F, 166295351.F, 166202650.F, 166109950.F, 166017249.F, 165924549.F, 165831848.F, 165739148.F,
    165646820.F},
    {165646820.F, 164808501.F, 164044541.F, 163342809.F, 162699005.F, 162104815.F, 161548283.F, 161022006.F, 160531308.F, 160071218.F,
    159625899.F, 159216003.F, 158816327.F, 158441552.F, 158077747.F, 157734989.F, 157398714.F, 157085146.F, 156771577.F, 156482356.F,
    156195403.F, 155918281.F, 155655598.F, 155392916.F, 155145199.F, 154904655.F, 154664111.F, 154437902.F, 154217563.F, 153997223.F,
    153785844.F, 153583948.F, 153382052.F, 153180156.F, 152994828.F, 152809771.F, 152624714.F, 152442438.F, 152272759.F, 152103079.F,
    151933399.F, 151764453.F, 151608818.F, 151453183.F, 151297548.F, 151141914.F, 150993613.F, 150850809.F, 150708005.F, 150565200.F,
    150422396.F, 150287927.F, 150156846.F, 150025765.F, 149894685.F, 149763604.F, 149637236.F, 149516870.F, 149396504.F, 149276139.F,
    149155773.F, 149035407.F, 148922153.F, 148811585.F, 148701017.F, 148590449.F, 148479880.F, 148369312.F, 148263532.F, 148161926.F,
    148060321.F, 147958715.F, 147857110.F, 147755504.F, 147653899.F, 147559077.F, 147465673.F, 147372268.F, 147278863.F, 147185459.F,
    147092054.F, 146998649.F, 146909486.F, 146823587.F, 146737688.F, 146651789.F, 146565890.F, 146479991.F, 146394092.F, 146308193.F,
    146227135.F},
    {146227135.F, 145450700.F, 144740647.F, 144087078.F, 143481362.F, 142915985.F, 142391848.F, 141900981.F, 141434906.F, 140989016.F,
    140577172.F, 140178958.F, 139798566.F, 139439495.F, 139087985.F, 138760677.F, 138435697.F, 138133786.F, 137833186.F, 137551199.F,
    137273008.F, 137006257.F, 136748677.F, 136493157.F, 136254544.F, 136015932.F, 135785697.F, 135564543.F, 135343390.F, 135132794.F,
    134927720.F, 134722645.F, 134526843.F, 134336580.F, 134146317.F, 133961167.F, 133784554.F, 133607942.F, 133431330.F, 133265891.F,
    133101864.F, 132937837.F, 132775560.F, 132623140.F, 132470720.F, 132318300.F, 132167461.F, 132025751.F, 131884040.F, 131742330.F,
    131600619.F, 131467428.F, 131335603.F, 131203778.F, 131071953.F, 130942646.F, 130819953.F, 130697260.F, 130574567.F, 130451874.F,
    130332313.F, 130218063.F, 130103812.F, 129989562.F, 129875311.F, 129762060.F, 129655618.F, 129549176.F, 129442734.F, 129336291.F,
    129229849.F, 129127208.F, 129027991.F, 128928774.F, 128829556.F, 128730339.F, 128631122.F, 128535543.F, 128443013.F, 128350483.F,
    128257954.F, 128165424.F, 128072894.F, 127981350.F, 127895013.F, 127808677.F, 127722340.F, 127636004.F, 127549667.F, 127463330.F,
    127378988.F},
    {127378988.F, 126589403.F, 125862946.F, 125191920.F, 124569493.F, 123989611.F, 123446908.F, 122936619.F, 122454519.F, 121996866.F,
    121560344.F, 121143877.F, 120751139.F, 120372269.F, 120005224.F, 119660290.F, 119323675.F, 118999583.F, 118689075.F, 118384324.F,
    118096002.F, 117809529.F, 117539708.F, 117269994.F, 117015942.F, 116761890.F, 116520899.F, 116281591.F, 116051175.F, 115825659.F,
    115603723.F, 115391114.F, 115178506.F, 114975297.F, 114774772.F, 114575831.F, 114386625.F, 114197420.F, 114012000.F, 113833400.F,
    113654801.F, 113480400.F, 113311743.F, 113143086.F, 112977495.F, 112818162.F, 112658829.F, 112500104.F, 112349519.F, 112198934.F,
    112048349.F, 111902992.F, 111760618.F, 111618244.F, 111476043.F, 111341380.F, 111206717.F, 111072053.F, 110938975.F, 110811555.F,
    110684135.F, 110556714.F, 110430775.F, 110310162.F, 110189548.F, 110068935.F, 109948385.F, 109834171.F, 109719957.F, 109605744.F,
    109491530.F, 109380848.F, 109272653.F, 109164459.F, 109056264.F, 108948069.F, 108845193.F, 108742662.F, 108640130.F, 108537599.F,
    108435373.F, 108338172.F, 108240972.F, 108143771.F, 108046570.F, 107949369.F, 107856844.F, 107764663.F, 107672482.F, 107580301.F,
    107488119.F},
    {107488119.F, 106628877.F, 105839498.F, 105110853.F, 104434065.F, 103803700.F, 103210557.F, 102651209.F, 102123331.F, 101623950.F,
    101148674.F, 100695260.F, 100261656.F,  99847517.F,  99450914.F,  99069545.F,  98701910.F,  98346641.F,  98002956.F,  97674192.F,
      97354626.F,  97043271.F,  96743411.F,  96452517.F,  96167466.F,  95893231.F,  95625177.F,  95362796.F,  95109926.F,  94859883.F,
      94619467.F,  94381974.F,  94151733.F,  93925388.F,  93704824.F,  93488348.F,  93276990.F,  93069221.F,  92866622.F,  92666502.F,
      92472241.F,  92278807.F,  92092484.F,  91906161.F,  91726099.F,  91547337.F,  91371936.F,  91200375.F,  91028935.F,  90864237.F,
      90699539.F,  90537969.F,  90379813.F,  90221656.F,  90068775.F,  89916856.F,  89765637.F,  89619667.F,  89473697.F,  89329382.F,
      89189087.F,  89048792.F,  88910474.F,  88775595.F,  88640716.F,  88507566.F,  88377857.F,  88248148.F,  88119416.F,  87994643.F,
      87869870.F,  87745098.F,  87624814.F,  87504756.F,  87384698.F,  87267318.F,  87151764.F,  87036211.F,  86921182.F,  86809933.F,
      86698684.F,  86587435.F,  86478373.F,  86371239.F,  86264105.F,  86156972.F,  86053065.F,  85949866.F,  85846666.F,  85743467.F,
      85643975.F},
    { 85643975.F,  84684988.F,  83803466.F,  82989996.F,  82232982.F,  81525015.F,  80861073.F,  80234266.F,  79639493.F,  79077334.F,
      78539785.F,  78028997.F,  77538646.F,  77069243.F,  76619102.F,  76185369.F,  75767056.F,  75363408.F,  74974500.F,  74598050.F,
      74233320.F,  73879619.F,  73536296.F,  73202741.F,  72878382.F,  72562680.F,  72255129.F,  71955255.F,  71663074.F,  71378456.F,
      71100376.F,  70828452.F,  70562327.F,  70301662.F,  70046979.F,  69798212.F,  69554057.F,  69314239.F,  69079136.F,  68849488.F,
      68623476.F,  68400884.F,  68183434.F,  67969553.F,  67758518.F,  67551875.F,  67348651.F,  67147775.F,  66951234.F,  66757368.F,
      66565631.F,  66378331.F,  66192680.F,  66010087.F,  65830336.F,  65652094.F,  65477865.F,  65304731.F,  65134775.F,  64966608.F,
      64800597.F,  64637081.F,  64474889.F,  64315729.F,  64157236.F,  64002153.F,  63847414.F,  63695979.F,  63544918.F,  63396849.F,
      63249233.F,  63104426.F,  62960036.F,  62818392.F,  62677020.F,  62538444.F,  62399898.F,  62264296.F,  62128694.F,  61995676.F,
      61862959.F,  61732327.F,  61602409.F,  61474007.F,  61346804.F,  61220485.F,  61095916.F,  60971542.F,  60849531.F,  60727519.F,
      60607443.F},
    { 60607443.F,  59457758.F,  58395967.F,  57408049.F,  56484239.F,  55614472.F,  54793552.F,  54014602.F,  53273088.F,  52565060.F,
      51887074.F,  51236751.F,  50611145.F,  50007630.F,  49425233.F,  48861279.F,  48315108.F,  47784507.F,  47269246.F,  46767586.F,
      46278569.F,  45801764.F,  45336206.F,  44881017.F,  44435582.F,  43999332.F,  43571735.F,  43152464.F,  42740859.F,  42336487.F,
      41938953.F,  41547890.F,  41162953.F,  40783808.F,  40410127.F,  40041600.F,  39677933.F,  39318854.F,  38964107.F,  38613445.F,
      38266638.F,  37923462.F,  37583708.F,  37247171.F,  36913657.F,  36583010.F,  36255010.F,  35929474.F,  35606227.F,  35285095.F,
      34965911.F,  34648511.F,  34332739.F,  34018443.F,  33705474.F,  33393685.F,  33082930.F,  32773060.F,  32463914.F,  32155312.F,
      31847078.F,  31539017.F,  31230935.F,  30922635.F,  30613910.F,  30304548.F,  29994312.F,  29682933.F,  29370200.F,  29055877.F,
      28739576.F,  28421091.F,  28099999.F,  27775919.F,  27448391.F,  27117011.F,  26781022.F,  26439963.F,  26093078.F,  25739496.F,
      25378210.F,  25008053.F,  24627600.F,  24234630.F,  23827010.F,  23401407.F,  22953684.F,  22478245.F,  21966677.F,  21405612.F,
      20771989.F}
};

const float invLUT_midTimeHi[101] {
     50685.F,    573112.F,   1031468.F,   1482359.F,   1930890.F,   2379001.F,   2814675.F,   3233276.F,   3637278.F,   4032849.F,
   4422451.F,   4807281.F,   5187081.F,   5561629.F,   5931495.F,   6297186.F,   6659130.F,   7017695.F,   7373165.F,   7725646.F,
   8075402.F,   8422739.F,   8767943.F,   9111239.F,   9452770.F,   9792654.F,  10130999.F,  10467982.F,  10803909.F,  11139070.F,
  11473740.F,  11808151.F,  12142495.F,  12476951.F,  12811690.F,  13146878.F,  13482674.F,  13819231.F,  14156716.F,  14495307.F,
  14835181.F,  15176503.F,  15519450.F,  15864187.F,  16210874.F,  16559676.F,  16910806.F,  17264420.F,  17620780.F,  17980043.F,
  18342449.F,  18708229.F,  19077574.F,  19450716.F,  19827919.F,  20209464.F,  20595598.F,  20986613.F,  21382816.F,  21784523.F,
  22192064.F,  22605803.F,  23026125.F,  23453448.F,  23888219.F,  24330922.F,  24782085.F,  25242288.F,  25712161.F,  26192365.F,
  26683627.F,  27186745.F,  27702604.F,  28232187.F,  28776588.F,  29337139.F,  29915220.F,  30512226.F,  31129775.F,  31770196.F,
  32435201.F,  33127846.F,  33850720.F,  34607410.F,  35402198.F,  36239623.F,  37125793.F,  38067318.F,  39072786.F,  40152893.F,
  41321553.F,  42596077.F,  44000348.F,  45566437.F,  47340686.F,  49395582.F,  51844694.F,  54894147.F,  58975940.F,  65292825.F,
  91755864.F};

int logfloor (uint32_t n) {
    if (n < 10) return 0;
    if (n < 100) return 1;
    if (n < 1000) return 2;
    if (n < 10000) return 3;
    if (n < 100000) return 4;
    if (n < 1000000) return 5;
    if (n < 10000000) return 6;
    if (n < 100000000) return 7;
    if (n < 1000000000) return 8;
    /*      2147483647 is 2^31-1 - add more ifs as needed
       and adjust this final return as well. */
    return 10;
}

float LinInterpFixed(float mantissa, const float *LUT) {
  static int LUTindex;
  static float slope, remainder, estimate;
  LUTindex = floorf(INVLUTSTEP*(mantissa-1.F));
  slope = (LUT[LUTindex+1] - LUT[LUTindex])*INVLUTSTEP;
  remainder = mantissa - 1 - LUTindex*LUTSTEP; 
  estimate = LUT[LUTindex] + slope*remainder;
  return roundf(estimate);
}

float Photon_Estimator(uint32_t pulses, uint32_t timeHi, int logfreq) {
  static float photon_estimate;
  static int decade, LUTblock;
  static float mantissa;
  static float pctTimeHi; 
  
  pctTimeHi= 16*timeHi*powf(10.F, (float) logfreq - 7.F); //TODO: Explain this
  if (pctTimeHi < ESTCUTOFF_LIN) {
    photon_estimate = (float) pulses;
  }
  else if (pctTimeHi < ESTCUTOFF_LOW) {
    decade = logfloor(pulses);
    mantissa = pulses/powf(10.F, (float) decade);
    LUTblock = decade + logfreq - LUTOFFSET_LOW;
    photon_estimate = LinInterpFixed(mantissa, invLUT_lowPulses[LUTblock])/powf(10.F, logfreq);
  }
  else if (pctTimeHi < ESTCUTOFF_HIGH) {
    mantissa = 1.F + pctTimeHi/10.F;
    photon_estimate = LinInterpFixed(mantissa, invLUT_midTimeHi)/powf(10.F, logfreq);
  }
  else {
    decade = logfloor(pulses);
    mantissa = pulses/powf(10.F, (float) decade);
    LUTblock = decade + logfreq - LUTOFFSET_HIGH;
    photon_estimate = LinInterpFixed(mantissa, invLUT_hiPulses[LUTblock])/powf(10.F, logfreq);
  }
  return photon_estimate;
}