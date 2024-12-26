module Korba
  class SGP4
    #     copied from https://github.com/aholinch/sgp4
    #     ----------------------------------------------------------------
    #
    #                               sgp4unit.cpp
    #
    #    this file contains the sgp4 procedures for analytical propagation
    #    of a satellite. the code was originally released in the 1980 and 1986
    #    spacetrack papers. a detailed discussion of the theory and history
    #    may be found in the 2006 aiaa paper by vallado, crawford, hujsak,
    #    and kelso.
    #    このファイルには、衛星の解析的伝播のためのsgp4手順が含まれています。
    #    コードは元々1980年と1986年のスペーストラック論文で公開されました。
    #    理論と歴史の詳細な議論は、ヴァラド、クロフォード、フジャック、
    #    ケルソによる2006年のAIAA論文に記載されています。
    #
    #                            companion code for
    #               fundamentals of astrodynamics and applications
    #                                    2013
    #                              by david vallado
    #
    #     (w) 719-573-2600, email dvallado@agi.com, davallado@gmail.com
    #
    #    current :
    #               7 dec 15  david vallado
    #                           fix jd, jdfrac
    #    changes :
    #               3 nov 14  david vallado
    #                           update to msvs2013 c++
    #              30 aug 10  david vallado
    #                           delete unused variables in initl
    #                           replace pow integer 2, 3 with multiplies for speed
    #               3 nov 08  david vallado
    #                           put returns in for error codes
    #              29 sep 08  david vallado
    #                           fix atime for faster operation in dspace
    #                           add operationmode for afspc (a) or improved (i)
    #                           performance mode
    #              16 jun 08  david vallado
    #                           update small eccentricity check
    #              16 nov 07  david vallado
    #                           misc fixes for better compliance
    #              20 apr 07  david vallado
    #                           misc fixes for constants
    #              11 aug 06  david vallado
    #                           chg lyddane choice back to strn3, constants, misc doc
    #              15 dec 05  david vallado
    #                           misc fixes
    #              26 jul 05  david vallado
    #                           fixes for paper
    #                           note that each fix is preceded by a
    #                           comment with "sgp4fix" and an explanation of
    #                           what was changed
    #              10 aug 04  david vallado
    #                           2nd printing baseline working
    #              14 may 01  david vallado
    #                           2nd edition baseline
    #                     80  norad
    #                           original baseline
    #       ----------------------------------------------------------------      */

    PI = Math::PI
    TWOPI = 2.0 * Math::PI
    DEG2RAD = PI / 180.0

    WGS72old = 1
    WGS72 = 2
    WGS84 = 3

    # -----------------------------------------------------------------------------
    #
    #                           procedure dpper
    #
    #  this procedure provides deep space long period periodic contributions
    #    to the mean elements.  by design, these periodics are zero at epoch.
    #    this used to be dscom which included initialization, but it's really a
    #    recurring function.
    #  この手順は、平均要素に対する深宇宙の長周期の周期的寄与を提供します。
    #   設計上、これらの周期的寄与はエポック時にゼロです。
    #   以前は初期化を含む dscom でしたが、実際には再帰的な関数です。
    #
    #  author        : david vallado                  719-573-2600   28 jun 2005
    #
    #  inputs        :
    #    e3          -
    #    ee2         -
    #    peo         -
    #    pgho        -
    #    pho         -
    #    pinco       -
    #    plo         -
    #    se2 , se3 , sgh2, sgh3, sgh4, sh2, sh3, si2, si3, sl2, sl3, sl4 -
    #    t           -
    #    xh2, xh3, xi2, xi3, xl2, xl3, xl4 -
    #    zmol        -
    #    zmos        -
    #    ep          - eccentricity                           0.0 - 1.0
    #    inclo       - inclination - needed for lyddane modification
    #    nodep       - right ascension of ascending node
    #    argpp       - argument of perigee
    #    mp          - mean anomaly
    #
    #  outputs       :
    #    ep          - eccentricity                           0.0 - 1.0
    #    inclp       - inclination
    #    nodep        - right ascension of ascending node
    #    argpp       - argument of perigee
    #    mp          - mean anomaly
    #
    #  locals        :
    #    alfdp       -
    #    betdp       -
    #    cosip  , sinip  , cosop  , sinop  ,
    #    dalf        -
    #    dbet        -
    #    dls         -
    #    f2, f3      -
    #    pe          -
    #    pgh         -
    #    ph          -
    #    pinc        -
    #    pl          -
    #    sel   , ses   , sghl  , sghs  , shl   , shs   , sil   , sinzf , sis   ,
    #    sll   , sls
    #    xls         -
    #    xnoh        -
    #    zf          -
    #    zm          -
    #
    #  coupling      :
    #    none.
    #
    #  references    :
    #    hoots, roehrich, norad spacetrack report #3 1980
    #    hoots, norad spacetrack report #6 1986
    #    hoots, schumacher and glover 2004
    #    vallado, crawford, hujsak, kelso  2006
    #---------------------------------------------------------------------------*/

    def self.dpper(e3, ee2, peo, pgho, pho, pinco, plo, se2, se3, sgh2,
                   sgh3, sgh4, sh2, sh3, si2, si3, sl2, sl3, sl4, t,
                   xgh2, xgh3, xgh4, xh2, xh3, xi2, xi3, xl2, xl3, xl4,
                   zmol, zmos, init, rec, opsmode)

      # --------------------- local variables ------------------------ */
      #double alfdp, betdp, cosip, cosop, dalf, dbet, dls,
      #  f2, f3, pe, pgh, ph, pinc, pl,
      #  sel, ses, sghl, sghs, shll, shs, sil,
      #  sinip, sinop, sinzf, sis, sll, sls, xls,
      #  xnoh, zf, zm, zel, zes, znl, zns

      #/* ---------------------- constants ----------------------------- */
      zns = 1.19459e-5
      zes = 0.01675
      znl = 1.5835218e-4
      zel = 0.05490

      #/* --------------- calculate time varying periodics ----------- */
      zm = zmos + zns * t
      #// be sure that the initial call has time set to zero
      if init == "y"
        zm = zmos
      end

      zf = zm + 2.0 * zes * Math.sin(zm)
      sinzf = Math.sin(zf)
      f2 = 0.5 * sinzf * sinzf - 0.25
      f3 = -0.5 * sinzf * Math.cos(zf)
      ses = se2 * f2 + se3 * f3
      sis = si2 * f2 + si3 * f3
      sls = sl2 * f2 + sl3 * f3 + sl4 * sinzf
      sghs = sgh2 * f2 + sgh3 * f3 + sgh4 * sinzf
      shs = sh2 * f2 + sh3 * f3
      zm = zmol + znl * t
      if init == "y"
        zm = zmol
      end

      zf = zm + 2.0 * zel * Math.sin(zm)
      sinzf = Math.sin(zf)
      f2 = 0.5 * sinzf * sinzf - 0.25
      f3 = -0.5 * sinzf * Math.cos(zf)
      sel = ee2 * f2 + e3 * f3
      sil = xi2 * f2 + xi3 * f3
      sll = xl2 * f2 + xl3 * f3 + xl4 * sinzf
      sghl = xgh2 * f2 + xgh3 * f3 + xgh4 * sinzf
      shll = xh2 * f2 + xh3 * f3
      pe = ses + sel
      pinc = sis + sil
      pl = sls + sll
      pgh = sghs + sghl
      ph = shs + shll

      if init == "n"
        pe = pe - peo
        pinc = pinc - pinco
        pl = pl - plo
        pgh = pgh - pgho
        ph = ph - pho
        rec.inclp = rec.inclp + pinc
        rec.ep = rec.ep + pe
        sinip = Math.sin(rec.inclp)
        cosip = Math.cos(rec.inclp)

        #/* ----------------- apply periodics directly ------------ */
        #//  sgp4fix for lyddane choice
        #//  strn3 used original inclination - this is technically feasible
        #//  gsfc used perturbed inclination - also technically feasible
        #//  probably best to readjust the 0.2 limit value and limit discontinuity
        #//  0.2 rad = 11.45916 deg
        #//  use next line for original strn3 approach and original inclination
        #//  if (inclo >= 0.2)
        #//  use next line for gsfc version and perturbed inclination
        if rec.inclp >= 0.2
          ph = ph / sinip
          pgh = pgh - cosip * ph
          rec.argpp = rec.argpp + pgh
          rec.nodep = rec.nodep + ph
          rec.mp = rec.mp + pl
        else
          #/* ---- apply periodics with lyddane modification ---- */
          sinop = Math.sin(rec.nodep)
          cosop = Math.cos(rec.nodep)
          alfdp = sinip * sinop
          betdp = sinip * cosop
          dalf = ph * cosop + pinc * cosip * sinop
          dbet = -ph * sinop + pinc * cosip * cosop
          alfdp = alfdp + dalf
          betdp = betdp + dbet
          rec.nodep = fmod(rec.nodep, TWOPI)
          #//  sgp4fix for afspc written intrinsic functions
          #// nodep used without a trigonometric function ahead
          if (rec.nodep < 0.0) and (opsmode == "a")
            rec.nodep = rec.nodep + TWOPI
          end
          xls = rec.mp + rec.argpp + cosip * rec.nodep
          dls = pl + pgh - pinc * rec.nodep * sinip
          xls = xls + dls
          xls = fmod(xls, TWOPI)
          xnoh = rec.nodep
          rec.nodep = Math.atan2(alfdp, betdp)
          #//  sgp4fix for afspc written intrinsic functions
          #// nodep used without a trigonometric function ahead
          if (rec.nodep < 0.0) and (opsmode == "a")
            rec.nodep = rec.nodep + TWOPI
          end
          if (xnoh - rec.nodep).abs > PI
            if (rec.nodep < xnoh)
              rec.nodep = rec.nodep + TWOPI
            else
              rec.nodep = rec.nodep - TWOPI
            end
          end
          rec.mp = rec.mp + pl
          rec.argpp = xls - rec.mp - cosip * rec.nodep
        end
        #   // if init == 'n'
      end

      #// dpper
    end

    #/*-----------------------------------------------------------------------------
    #*
    #*                           procedure dscom
    #*
    #*  this procedure provides deep space common items used by both the secular
    #*    and periodics subroutines.  input is provided as shown. this routine
    #*    used to be called dpper, but the functions inside weren't well organized.
    #*  この手順は、深宇宙の共通項目を提供し、世俗的および周期的なサブルーチンの両方で使用されます。
    #*    入力は以下のように提供されます。このルーチンは以前はdpperと呼ばれていましたが、
    #*    内部の関数がうまく整理されていませんでした。
    #*
    #*  author        : david vallado                  719-573-2600   28 jun 2005
    #*
    #*  inputs        :
    #*    epoch       -
    #*    ep          - eccentricity
    #*    argpp       - argument of perigee
    #*    tc          -
    #*    inclp       - inclination
    #*    nodep       - right ascension of ascending node
    #*    np          - mean motion
    #*
    #*  outputs       :
    #*    sinim  , cosim  , sinomm , cosomm , snodm  , cnodm
    #*    day         -
    #*    e3          -
    #*    ee2         -
    #*    em          - eccentricity
    #*    emsq        - eccentricity squared
    #*    gam         -
    #*    peo         -
    #*    pgho        -
    #*    pho         -
    #*    pinco       -
    #*    plo         -
    #*    rtemsq      -
    #*    se2, se3         -
    #*    sgh2, sgh3, sgh4        -
    #*    sh2, sh3, si2, si3, sl2, sl3, sl4         -
    #*    s1, s2, s3, s4, s5, s6, s7          -
    #*    ss1, ss2, ss3, ss4, ss5, ss6, ss7, sz1, sz2, sz3         -
    #*    sz11, sz12, sz13, sz21, sz22, sz23, sz31, sz32, sz33        -
    #*    xgh2, xgh3, xgh4, xh2, xh3, xi2, xi3, xl2, xl3, xl4         -
    #*    nm          - mean motion
    #*    z1, z2, z3, z11, z12, z13, z21, z22, z23, z31, z32, z33         -
    #*    zmol        -
    #*    zmos        -
    #*
    #*  locals        :
    #*    a1, a2, a3, a4, a5, a6, a7, a8, a9, a10         -
    #*    betasq      -
    #*    cc          -
    #*    ctem, stem        -
    #*    x1, x2, x3, x4, x5, x6, x7, x8          -
    #*    xnodce      -
    #*    xnoi        -
    #*    zcosg  , zsing  , zcosgl , zsingl , zcosh  , zsinh  , zcoshl , zsinhl ,
    #*    zcosi  , zsini  , zcosil , zsinil ,
    #*    zx          -
    #*    zy          -
    #*
    #*  coupling      :
    #*    none.
    #*
    #*  references    :
    #*    hoots, roehrich, norad spacetrack report #3 1980
    #*    hoots, norad spacetrack report #6 1986
    #*    hoots, schumacher and glover 2004
    #*    vallado, crawford, hujsak, kelso  2006
    #----------------------------------------------------------------------------*/

    def self.dscom(epoch, ep, argpp, tc, inclp, nodep, np, rec)
      #/* -------------------------- constants ------------------------- */
      zes = 0.01675
      zel = 0.05490
      c1ss = 2.9864797e-6
      c1l = 4.7968065e-7
      zsinis = 0.39785416
      zcosis = 0.91744867
      zcosgs = 0.1945905
      zsings = -0.98088458

      #/* --------------------- local variables ------------------------ */
      #int lsflg
      #double a1, a2, a3, a4, a5, a6, a7,
      #  a8, a9, a10, betasq, cc, ctem, stem,
      #  x1, x2, x3, x4, x5, x6, x7,
      #  x8, xnodce, xnoi, zcosg, zcosgl, zcosh, zcoshl,
      #  zcosi, zcosil, zsing, zsingl, zsinh, zsinhl, zsini,
      #  zsinil, zx, zy

      rec.nm = np
      rec.em = ep
      rec.snodm = Math.sin(nodep)
      rec.cnodm = Math.cos(nodep)
      rec.sinomm = Math.sin(argpp)
      rec.cosomm = Math.cos(argpp)
      rec.sinim = Math.sin(inclp)
      rec.cosim = Math.cos(inclp)
      rec.emsq = rec.em * rec.em
      betasq = 1.0 - rec.emsq
      rec.rtemsq = Math.sqrt(betasq)

      #/* ----------------- initialize lunar solar terms --------------- */
      rec.peo = 0.0
      rec.pinco = 0.0
      rec.plo = 0.0
      rec.pgho = 0.0
      rec.pho = 0.0
      rec.day = epoch + 18261.5 + tc / 1440.0
      xnodce = fmod(4.5236020 - 9.2422029e-4 * rec.day, TWOPI)
      stem = Math.sin(xnodce)
      ctem = Math.cos(xnodce)
      zcosil = 0.91375164 - 0.03568096 * ctem
      zsinil = Math.sqrt(1.0 - zcosil * zcosil)
      zsinhl = 0.089683511 * stem / zsinil
      zcoshl = Math.sqrt(1.0 - zsinhl * zsinhl)
      rec.gam = 5.8351514 + 0.0019443680 * rec.day
      zx = 0.39785416 * stem / zsinil
      zy = zcoshl * ctem + 0.91744867 * zsinhl * stem
      zx = Math.atan2(zx, zy)
      zx = rec.gam + zx - xnodce
      zcosgl = Math.cos(zx)
      zsingl = Math.sin(zx)

      #/* ------------------------- do solar terms --------------------- */
      zcosg = zcosgs
      zsing = zsings
      zcosi = zcosis
      zsini = zsinis
      zcosh = rec.cnodm
      zsinh = rec.snodm
      cc = c1ss
      xnoi = 1.0 / rec.nm

      for lsflg in 1..3
        a1 = zcosg * zcosh + zsing * zcosi * zsinh
        a3 = -zsing * zcosh + zcosg * zcosi * zsinh
        a7 = -zcosg * zsinh + zsing * zcosi * zcosh
        a8 = zsing * zsini
        a9 = zsing * zsinh + zcosg * zcosi * zcosh
        a10 = zcosg * zsini
        a2 = rec.cosim * a7 + rec.sinim * a8
        a4 = rec.cosim * a9 + rec.sinim * a10
        a5 = -rec.sinim * a7 + rec.cosim * a8
        a6 = -rec.sinim * a9 + rec.cosim * a10

        x1 = a1 * rec.cosomm + a2 * rec.sinomm
        x2 = a3 * rec.cosomm + a4 * rec.sinomm
        x3 = -a1 * rec.sinomm + a2 * rec.cosomm
        x4 = -a3 * rec.sinomm + a4 * rec.cosomm
        x5 = a5 * rec.sinomm
        x6 = a6 * rec.sinomm
        x7 = a5 * rec.cosomm
        x8 = a6 * rec.cosomm

        rec.z31 = 12.0 * x1 * x1 - 3.0 * x3 * x3
        rec.z32 = 24.0 * x1 * x2 - 6.0 * x3 * x4
        rec.z33 = 12.0 * x2 * x2 - 3.0 * x4 * x4
        rec.z1 = 3.0 * (a1 * a1 + a2 * a2) + rec.z31 * rec.emsq
        rec.z2 = 6.0 * (a1 * a3 + a2 * a4) + rec.z32 * rec.emsq
        rec.z3 = 3.0 * (a3 * a3 + a4 * a4) + rec.z33 * rec.emsq
        rec.z11 = -6.0 * a1 * a5 + rec.emsq * (-24.0 * x1 * x7 - 6.0 * x3 * x5)
        rec.z12 = (-6.0 * (a1 * a6 + a3 * a5) + rec.emsq *
                                                (-24.0 * (x2 * x7 + x1 * x8) - 6.0 * (x3 * x6 + x4 * x5)))
        rec.z13 = -6.0 * a3 * a6 + rec.emsq * (-24.0 * x2 * x8 - 6.0 * x4 * x6)
        rec.z21 = 6.0 * a2 * a5 + rec.emsq * (24.0 * x1 * x5 - 6.0 * x3 * x7)
        rec.z22 = (6.0 * (a4 * a5 + a2 * a6) + rec.emsq *
                                               (24.0 * (x2 * x5 + x1 * x6) - 6.0 * (x4 * x7 + x3 * x8)))
        rec.z23 = 6.0 * a4 * a6 + rec.emsq * (24.0 * x2 * x6 - 6.0 * x4 * x8)
        rec.z1 = rec.z1 + rec.z1 + betasq * rec.z31
        rec.z2 = rec.z2 + rec.z2 + betasq * rec.z32
        rec.z3 = rec.z3 + rec.z3 + betasq * rec.z33
        rec.s3 = cc * xnoi
        rec.s2 = -0.5 * rec.s3 / rec.rtemsq
        rec.s4 = rec.s3 * rec.rtemsq
        rec.s1 = -15.0 * rec.em * rec.s4
        rec.s5 = x1 * x3 + x2 * x4
        rec.s6 = x2 * x3 + x1 * x4
        rec.s7 = x2 * x4 - x1 * x3

        #/* ----------------------- do lunar terms ------------------- */
        if lsflg == 1
          rec.ss1 = rec.s1
          rec.ss2 = rec.s2
          rec.ss3 = rec.s3
          rec.ss4 = rec.s4
          rec.ss5 = rec.s5
          rec.ss6 = rec.s6
          rec.ss7 = rec.s7
          rec.sz1 = rec.z1
          rec.sz2 = rec.z2
          rec.sz3 = rec.z3
          rec.sz11 = rec.z11
          rec.sz12 = rec.z12
          rec.sz13 = rec.z13
          rec.sz21 = rec.z21
          rec.sz22 = rec.z22
          rec.sz23 = rec.z23
          rec.sz31 = rec.z31
          rec.sz32 = rec.z32
          rec.sz33 = rec.z33
          zcosg = zcosgl
          zsing = zsingl
          zcosi = zcosil
          zsini = zsinil
          zcosh = zcoshl * rec.cnodm + zsinhl * rec.snodm
          zsinh = rec.snodm * zcoshl - rec.cnodm * zsinhl
          cc = c1l
        end
        #end lsflg == 1
      end
      # end for loop

      rec.zmol = fmod(4.7199672 + 0.22997150 * rec.day - rec.gam, TWOPI)
      rec.zmos = fmod(6.2565837 + 0.017201977 * rec.day, TWOPI)

      #/* ------------------------ do solar terms ---------------------- */
      rec.se2 = 2.0 * rec.ss1 * rec.ss6
      rec.se3 = 2.0 * rec.ss1 * rec.ss7
      rec.si2 = 2.0 * rec.ss2 * rec.sz12
      rec.si3 = 2.0 * rec.ss2 * (rec.sz13 - rec.sz11)
      rec.sl2 = -2.0 * rec.ss3 * rec.sz2
      rec.sl3 = -2.0 * rec.ss3 * (rec.sz3 - rec.sz1)
      rec.sl4 = -2.0 * rec.ss3 * (-21.0 - 9.0 * rec.emsq) * zes
      rec.sgh2 = 2.0 * rec.ss4 * rec.sz32
      rec.sgh3 = 2.0 * rec.ss4 * (rec.sz33 - rec.sz31)
      rec.sgh4 = -18.0 * rec.ss4 * zes
      rec.sh2 = -2.0 * rec.ss2 * rec.sz22
      rec.sh3 = -2.0 * rec.ss2 * (rec.sz23 - rec.sz21)

      #/* ------------------------ do lunar terms ---------------------- */
      rec.ee2 = 2.0 * rec.s1 * rec.s6
      rec.e3 = 2.0 * rec.s1 * rec.s7
      rec.xi2 = 2.0 * rec.s2 * rec.z12
      rec.xi3 = 2.0 * rec.s2 * (rec.z13 - rec.z11)
      rec.xl2 = -2.0 * rec.s3 * rec.z2
      rec.xl3 = -2.0 * rec.s3 * (rec.z3 - rec.z1)
      rec.xl4 = -2.0 * rec.s3 * (-21.0 - 9.0 * rec.emsq) * zel
      rec.xgh2 = 2.0 * rec.s4 * rec.z32
      rec.xgh3 = 2.0 * rec.s4 * (rec.z33 - rec.z31)
      rec.xgh4 = -18.0 * rec.s4 * zel
      rec.xh2 = -2.0 * rec.s2 * rec.z22
      rec.xh3 = -2.0 * rec.s2 * (rec.z23 - rec.z21)

      #}  // dscom
    end

    #/*-----------------------------------------------------------------------------
    #*
    #*                           procedure dsinit
    #*
    #*  this procedure provides deep space contributions to mean motion dot due
    #*    to geopotential resonance with half day and one day orbits.
    #*  この手順は、半日および一日の軌道との重力共鳴による平均運動ドットへの深宇宙寄与を提供します。
    #*
    #*  author        : david vallado                  719-573-2600   28 jun 2005
    #*
    #*  inputs        :
    #*    xke         - reciprocal of tumin
    #*    cosim, sinim-
    #*    emsq        - eccentricity squared
    #*    argpo       - argument of perigee
    #*    s1, s2, s3, s4, s5      -
    #*    ss1, ss2, ss3, ss4, ss5 -
    #*    sz1, sz3, sz11, sz13, sz21, sz23, sz31, sz33 -
    #*    t           - time
    #*    tc          -
    #*    gsto        - greenwich sidereal time                   rad
    #*    mo          - mean anomaly
    #*    mdot        - mean anomaly dot (rate)
    #*    no          - mean motion
    #*    nodeo       - right ascension of ascending node
    #*    nodedot     - right ascension of ascending node dot (rate)
    #*    xpidot      -
    #*    z1, z3, z11, z13, z21, z23, z31, z33 -
    #*    eccm        - eccentricity
    #*    argpm       - argument of perigee
    #*    inclm       - inclination
    #*    mm          - mean anomaly
    #*    xn          - mean motion
    #*    nodem       - right ascension of ascending node
    #*
    #*  outputs       :
    #*    em          - eccentricity
    #*    argpm       - argument of perigee
    #*    inclm       - inclination
    #*    mm          - mean anomaly
    #*    nm          - mean motion
    #*    nodem       - right ascension of ascending node
    #*    irez        - flag for resonance           0-none, 1-one day, 2-half day
    #*    atime       -
    #*    d2201, d2211, d3210, d3222, d4410, d4422, d5220, d5232, d5421, d5433    -
    #*    dedt        -
    #*    didt        -
    #*    dmdt        -
    #*    dndt        -
    #*    dnodt       -
    #*    domdt       -
    #*    del1, del2, del3        -
    #*    ses  , sghl , sghs , sgs  , shl  , shs  , sis  , sls
    #*    theta       -
    #*    xfact       -
    #*    xlamo       -
    #*    xli         -
    #*    xni
    #*
    #*  locals        :
    #*    ainv2       -
    #*    aonv        -
    #*    cosisq      -
    #*    eoc         -
    #*    f220, f221, f311, f321, f322, f330, f441, f442, f522, f523, f542, f543  -
    #*    g200, g201, g211, g300, g310, g322, g410, g422, g520, g521, g532, g533  -
    #*    sini2       -
    #*    temp        -
    #*    temp1       -
    #*    theta       -
    #*    xno2        -
    #*
    #*  coupling      :
    #*    getgravconst- no longer used
    #*
    #*  references    :
    #*    hoots, roehrich, norad spacetrack report #3 1980
    #*    hoots, norad spacetrack report #6 1986
    #*    hoots, schumacher and glover 2004
    #*    vallado, crawford, hujsak, kelso  2006
    #----------------------------------------------------------------------------*/
    def self.dsinit(tc, xpidot, rec)
      #/* --------------------- local variables ------------------------ */

      #double ainv2, aonv = 0.0, cosisq, eoc, f220, f221, f311,
      #  f321, f322, f330, f441, f442, f522, f523,
      #  f542, f543, g200, g201, g211, g300, g310,
      #  g322, g410, g422, g520, g521, g532, g533,
      #  ses, sgs, sghl, sghs, shs, shll, sis,
      #  sini2, sls, temp, temp1, theta, xno2, q22,
      #  q31, q33, root22, root44, root54, rptim, root32,
      #  root52, x2o3, znl, emo, zns, emsqo

      q22 = 1.7891679e-6
      q31 = 2.1460748e-6
      q33 = 2.2123015e-7
      root22 = 1.7891679e-6
      root44 = 7.3636953e-9
      root54 = 2.1765803e-9
      rptim = 4.37526908801129966e-3 #// this equates to 7.29211514668855e-5 rad/sec
      root32 = 3.7393792e-7
      root52 = 1.1428639e-7
      x2o3 = 2.0 / 3.0
      znl = 1.5835218e-4
      zns = 1.19459e-5

      #// sgp4fix identify constants and allow alternate values
      #// just xke is used here so pass it in rather than have multiple calls
      #// getgravconst( whichconst, tumin, mu, radiusearthkm, xke, j2, j3, j4, j3oj2 )

      #/* -------------------- deep space initialization ------------ */
      rec.irez = 0
      if ((rec.nm < 0.0052359877) and (rec.nm > 0.0034906585))
        rec.irez = 1
      end
      if ((rec.nm >= 8.26e-3) and (rec.nm <= 9.24e-3) and (rec.em >= 0.5))
        rec.irez = 2
      end

      #/* ------------------------ do solar terms ------------------- */
      ses = rec.ss1 * zns * rec.ss5
      sis = rec.ss2 * zns * (rec.sz11 + rec.sz13)
      sls = -zns * rec.ss3 * (rec.sz1 + rec.sz3 - 14.0 - 6.0 * rec.emsq)
      sghs = rec.ss4 * zns * (rec.sz31 + rec.sz33 - 6.0)
      shs = -zns * rec.ss2 * (rec.sz21 + rec.sz23)
      #// sgp4fix for 180 deg incl
      if ((rec.inclm < 5.2359877e-2) or (rec.inclm > PI - 5.2359877e-2))
        shs = 0.0
      end
      if (rec.sinim != 0.0)
        shs = shs / rec.sinim
      end
      sgs = sghs - rec.cosim * shs

      #/* ------------------------- do lunar terms ------------------ */
      rec.dedt = ses + rec.s1 * znl * rec.s5
      rec.didt = sis + rec.s2 * znl * (rec.z11 + rec.z13)
      rec.dmdt = sls - znl * rec.s3 * (rec.z1 + rec.z3 - 14.0 - 6.0 * rec.emsq)
      sghl = rec.s4 * znl * (rec.z31 + rec.z33 - 6.0)
      shll = -znl * rec.s2 * (rec.z21 + rec.z23)
      #// sgp4fix for 180 deg incl
      if ((rec.inclm < 5.2359877e-2) or (rec.inclm > PI - 5.2359877e-2))
        shll = 0.0
      end
      rec.domdt = sgs + sghl
      rec.dnodt = shs
      if (rec.sinim != 0.0)
        rec.domdt = rec.domdt - rec.cosim / rec.sinim * shll
        rec.dnodt = rec.dnodt + shll / rec.sinim
      end

      #/* ----------- calculate deep space resonance effects -------- */
      rec.dndt = 0.0
      theta = fmod(rec.gsto + tc * rptim, TWOPI)
      rec.em = rec.em + rec.dedt * rec.t
      rec.inclm = rec.inclm + rec.didt * rec.t
      rec.argpm = rec.argpm + rec.domdt * rec.t
      rec.nodem = rec.nodem + rec.dnodt * rec.t
      rec.mm = rec.mm + rec.dmdt * rec.t
      #//   sgp4fix for negative inclinations
      #//   the following if statement should be commented out
      #//if (inclm < 0.0)
      #//  {
      #//    inclm  = -inclm
      #//    argpm  = argpm - pi
      #//    nodem = nodem + pi
      #//  }

      #/* -------------- initialize the resonance terms ------------- */
      if (rec.irez != 0)
        aonv = (rec.nm / rec.xke) ** x2o3

        #/* ---------- geopotential resonance for 12 hour orbits ------ */
        if (rec.irez == 2)
          cosisq = rec.cosim * rec.cosim
          emo = rec.em
          rec.em = rec.ecco
          emsqo = rec.emsq
          rec.emsq = rec.eccsq
          eoc = rec.em * rec.emsq
          g201 = -0.306 - (rec.em - 0.64) * 0.440

          if (rec.em <= 0.65)
            g211 = 3.616 - 13.2470 * rec.em + 16.2900 * rec.emsq
            g310 = -19.302 + 117.3900 * rec.em - 228.4190 * rec.emsq + 156.5910 * eoc
            g322 = -18.9068 + 109.7927 * rec.em - 214.6334 * rec.emsq + 146.5816 * eoc
            g410 = -41.122 + 242.6940 * rec.em - 471.0940 * rec.emsq + 313.9530 * eoc
            g422 = -146.407 + 841.8800 * rec.em - 1629.014 * rec.emsq + 1083.4350 * eoc
            g520 = -532.114 + 3017.977 * rec.em - 5740.032 * rec.emsq + 3708.2760 * eoc
          else
            g211 = -72.099 + 331.819 * rec.em - 508.738 * rec.emsq + 266.724 * eoc
            g310 = -346.844 + 1582.851 * rec.em - 2415.925 * rec.emsq + 1246.113 * eoc
            g322 = -342.585 + 1554.908 * rec.em - 2366.899 * rec.emsq + 1215.972 * eoc
            g410 = -1052.797 + 4758.686 * rec.em - 7193.992 * rec.emsq + 3651.957 * eoc
            g422 = -3581.690 + 16178.110 * rec.em - 24462.770 * rec.emsq + 12422.520 * eoc
            if (rec.em > 0.715)
              g520 = -5149.66 + 29936.92 * rec.em - 54087.36 * rec.emsq + 31324.56 * eoc
            else
              g520 = 1464.74 - 4664.75 * rec.em + 3763.64 * rec.emsq
            end
          end

          if (rec.em < 0.7)
            g533 = -919.22770 + 4988.6100 * rec.em - 9064.7700 * rec.emsq + 5542.21 * eoc
            g521 = -822.71072 + 4568.6173 * rec.em - 8491.4146 * rec.emsq + 5337.524 * eoc
            g532 = -853.66600 + 4690.2500 * rec.em - 8624.7700 * rec.emsq + 5341.4 * eoc
          else
            g533 = -37995.780 + 161616.52 * rec.em - 229838.20 * rec.emsq + 109377.94 * eoc
            g521 = -51752.104 + 218913.95 * rec.em - 309468.16 * rec.emsq + 146349.42 * eoc
            g532 = -40023.880 + 170470.89 * rec.em - 242699.48 * rec.emsq + 115605.82 * eoc
          end

          sini2 = rec.sinim * rec.sinim
          f220 = 0.75 * (1.0 + 2.0 * rec.cosim + cosisq)
          f221 = 1.5 * sini2
          f321 = 1.875 * rec.sinim * (1.0 - 2.0 * rec.cosim - 3.0 * cosisq)
          f322 = -1.875 * rec.sinim * (1.0 + 2.0 * rec.cosim - 3.0 * cosisq)
          f441 = 35.0 * sini2 * f220
          f442 = 39.3750 * sini2 * sini2
          f522 = (9.84375 * rec.sinim * (sini2 * (1.0 - 2.0 * rec.cosim - 5.0 * cosisq) +
                                         0.33333333 * (-2.0 + 4.0 * rec.cosim + 6.0 * cosisq)))
          f523 = (rec.sinim * (4.92187512 * sini2 * (-2.0 - 4.0 * rec.cosim +
                                                     10.0 * cosisq) + 6.56250012 * (1.0 + 2.0 * rec.cosim - 3.0 * cosisq)))
          f542 = (29.53125 * rec.sinim * (2.0 - 8.0 * rec.cosim + cosisq *
                                                                  (-12.0 + 8.0 * rec.cosim + 10.0 * cosisq)))
          f543 = (29.53125 * rec.sinim * (-2.0 - 8.0 * rec.cosim + cosisq *
                                                                   (12.0 + 8.0 * rec.cosim - 10.0 * cosisq)))
          xno2 = rec.nm * rec.nm
          ainv2 = aonv * aonv
          temp1 = 3.0 * xno2 * ainv2
          temp = temp1 * root22
          rec.d2201 = temp * f220 * g201
          rec.d2211 = temp * f221 * g211
          temp1 = temp1 * aonv
          temp = temp1 * root32
          rec.d3210 = temp * f321 * g310
          rec.d3222 = temp * f322 * g322
          temp1 = temp1 * aonv
          temp = 2.0 * temp1 * root44
          rec.d4410 = temp * f441 * g410
          rec.d4422 = temp * f442 * g422
          temp1 = temp1 * aonv
          temp = temp1 * root52
          rec.d5220 = temp * f522 * g520
          rec.d5232 = temp * f523 * g532
          temp = 2.0 * temp1 * root54
          rec.d5421 = temp * f542 * g521
          rec.d5433 = temp * f543 * g533
          rec.xlamo = fmod(rec.mo + rec.nodeo + rec.nodeo - theta - theta, TWOPI)
          rec.xfact = rec.mdot + rec.dmdt + 2.0 * (rec.nodedot + rec.dnodt - rptim) - rec.no_unkozai
          rec.em = emo
          rec.emsq = emsqo
        end
        #}

        #/* ---------------- synchronous resonance terms -------------- */
        if (rec.irez == 1)
          g200 = 1.0 + rec.emsq * (-2.5 + 0.8125 * rec.emsq)
          g310 = 1.0 + 2.0 * rec.emsq
          g300 = 1.0 + rec.emsq * (-6.0 + 6.60937 * rec.emsq)
          f220 = 0.75 * (1.0 + rec.cosim) * (1.0 + rec.cosim)
          f311 = 0.9375 * rec.sinim * rec.sinim * (1.0 + 3.0 * rec.cosim) - 0.75 * (1.0 + rec.cosim)
          f330 = 1.0 + rec.cosim
          f330 = 1.875 * f330 * f330 * f330
          rec.del1 = 3.0 * rec.nm * rec.nm * aonv * aonv
          rec.del2 = 2.0 * rec.del1 * f220 * g200 * q22
          rec.del3 = 3.0 * rec.del1 * f330 * g300 * q33 * aonv
          rec.del1 = rec.del1 * f311 * g310 * q31 * aonv
          rec.xlamo = fmod(rec.mo + rec.nodeo + rec.argpo - theta, TWOPI)
          rec.xfact = rec.mdot + xpidot - rptim + rec.dmdt + rec.domdt + rec.dnodt - rec.no_unkozai
        end

        #/* ------------ for sgp4, initialize the integrator ---------- */
        rec.xli = rec.xlamo
        rec.xni = rec.no_unkozai
        rec.atime = 0.0
        rec.nm = rec.no_unkozai + rec.dndt
      end
    end
    #}  // dsinit

    #/*-----------------------------------------------------------------------------
    #*
    #*                           procedure dspace
    #*
    #*  this procedure provides deep space contributions to mean elements for
    #*    perturbing third body.  these effects have been averaged over one
    #*    revolution of the sun and moon.  for earth resonance effects, the
    #*    effects have been averaged over no revolutions of the satellite.
    #*    (mean motion)
    #*  この手順は、摂動する第三体の平均要素に対する深宇宙寄与を提供します。
    #*    これらの効果は、太陽と月の1回の公転にわたって平均化されています。
    #*    地球の共鳴効果については、衛星の公転数にわたって効果が平均化されています。
    #*    （平均運動）
    #*
    #*  author        : david vallado                  719-573-2600   28 jun 2005
    #*
    #*  inputs        :
    #*    d2201, d2211, d3210, d3222, d4410, d4422, d5220, d5232, d5421, d5433 -
    #*    dedt        -
    #*    del1, del2, del3  -
    #*    didt        -
    #*    dmdt        -
    #*    dnodt       -
    #*    domdt       -
    #*    irez        - flag for resonance           0-none, 1-one day, 2-half day
    #*    argpo       - argument of perigee
    #*    argpdot     - argument of perigee dot (rate)
    #*    t           - time
    #*    tc          -
    #*    gsto        - gst
    #*    xfact       -
    #*    xlamo       -
    #*    no          - mean motion
    #*    atime       -
    #*    em          - eccentricity
    #*    ft          -
    #*    argpm       - argument of perigee
    #*    inclm       - inclination
    #*    xli         -
    #*    mm          - mean anomaly
    #*    xni         - mean motion
    #*    nodem       - right ascension of ascending node
    #*
    #*  outputs       :
    #*    atime       -
    #*    em          - eccentricity
    #*    argpm       - argument of perigee
    #*    inclm       - inclination
    #*    xli         -
    #*    mm          - mean anomaly
    #*    xni         -
    #*    nodem       - right ascension of ascending node
    #*    dndt        -
    #*    nm          - mean motion
    #*
    #*  locals        :
    #*    delt        -
    #*    ft          -
    #*    theta       -
    #*    x2li        -
    #*    x2omi       -
    #*    xl          -
    #*    xldot       -
    #*    xnddt       -
    #*    xndt        -
    #*    xomi        -
    #*
    #*  coupling      :
    #*    none        -
    #*
    #*  references    :
    #*    hoots, roehrich, norad spacetrack report #3 1980
    #*    hoots, norad spacetrack report #6 1986
    #*    hoots, schumacher and glover 2004
    #*    vallado, crawford, hujsak, kelso  2006
    #----------------------------------------------------------------------------*/

    def self.dspace(tc, rec)
      #int iretn
      #double delt, ft, theta, x2li, x2omi, xl, xldot, xnddt, xndt, xomi, g22, g32,
      #  g44, g52, g54, fasx2, fasx4, fasx6, rptim, step2, stepn, stepp

      xndt = 0
      xnddt = 0
      xldot = 0

      fasx2 = 0.13130908
      fasx4 = 2.8843198
      fasx6 = 0.37448087
      g22 = 5.7686396
      g32 = 0.95240898
      g44 = 1.8014998
      g52 = 1.0508330
      g54 = 4.4108898
      rptim = 4.37526908801129966e-3 #// this equates to 7.29211514668855e-5 rad/sec
      stepp = 720.0
      stepn = -720.0
      step2 = 259200.0

      #/* ----------- calculate deep space resonance effects ----------- */
      rec.dndt = 0.0
      theta = fmod(rec.gsto + tc * rptim, TWOPI)
      rec.em = rec.em + rec.dedt * rec.t

      rec.inclm = rec.inclm + rec.didt * rec.t
      rec.argpm = rec.argpm + rec.domdt * rec.t
      rec.nodem = rec.nodem + rec.dnodt * rec.t
      rec.mm = rec.mm + rec.dmdt * rec.t

      #//   sgp4fix for negative inclinations
      #//   the following if statement should be commented out
      #//  if (inclm < 0.0)
      #// {
      #//    inclm = -inclm
      #//    argpm = argpm - pi
      #//    nodem = nodem + pi
      #//  }

      #/* - update resonances : numerical (euler-maclaurin) integration - */
      #/* ------------------------- epoch restart ----------------------  */
      #//   sgp4fix for propagator problems
      #//   the following integration works for negative time steps and periods
      #//   the specific changes are unknown because the original code was so convoluted

      #// sgp4fix take out atime = 0.0 and fix for faster operation
      ft = 0.0
      if (rec.irez != 0)
        #// sgp4fix streamline check
        if ((rec.atime == 0.0) or (rec.t * rec.atime <= 0.0) or ((rec.t).abs < (rec.atime).abs))
          rec.atime = 0.0
          rec.xni = rec.no_unkozai
          rec.xli = rec.xlamo
        end
        #// sgp4fix move check outside loop
        if (rec.t > 0.0)
          delt = stepp
        else
          delt = stepn
        end

        iretn = 381 #// added for do loop
        while (iretn == 381)
          #/* ------------------- dot terms calculated ------------- */
          #/* ----------- near - synchronous resonance terms ------- */
          if (rec.irez != 2)
            xndt = (rec.del1 * Math.sin(rec.xli - fasx2) + rec.del2 * Math.sin(2.0 * (rec.xli - fasx4)) +
                    rec.del3 * Math.sin(3.0 * (rec.xli - fasx6)))
            xldot = rec.xni + rec.xfact
            xnddt = (rec.del1 * Math.cos(rec.xli - fasx2) +
                     2.0 * rec.del2 * Math.cos(2.0 * (rec.xli - fasx4)) +
                     3.0 * rec.del3 * Math.cos(3.0 * (rec.xli - fasx6)))
            xnddt = xnddt * xldot
          else
            #/* --------- near - half-day resonance terms -------- */
            xomi = rec.argpo + rec.argpdot * rec.atime
            x2omi = xomi + xomi
            x2li = rec.xli + rec.xli
            xndt = (rec.d2201 * Math.sin(x2omi + rec.xli - g22) + rec.d2211 * Math.sin(rec.xli - g22) +
                    rec.d3210 * Math.sin(xomi + rec.xli - g32) + rec.d3222 * Math.sin(-xomi + rec.xli - g32) +
                    rec.d4410 * Math.sin(x2omi + x2li - g44) + rec.d4422 * Math.sin(x2li - g44) +
                    rec.d5220 * Math.sin(xomi + rec.xli - g52) + rec.d5232 * Math.sin(-xomi + rec.xli - g52) +
                    rec.d5421 * Math.sin(xomi + x2li - g54) + rec.d5433 * Math.sin(-xomi + x2li - g54))
            xldot = rec.xni + rec.xfact
            xnddt = (rec.d2201 * Math.cos(x2omi + rec.xli - g22) + rec.d2211 * Math.cos(rec.xli - g22) +
                     rec.d3210 * Math.cos(xomi + rec.xli - g32) + rec.d3222 * Math.cos(-xomi + rec.xli - g32) +
                     rec.d5220 * Math.cos(xomi + rec.xli - g52) + rec.d5232 * Math.cos(-xomi + rec.xli - g52) +
                     2.0 * (rec.d4410 * Math.cos(x2omi + x2li - g44) +
                            rec.d4422 * Math.cos(x2li - g44) + rec.d5421 * Math.cos(xomi + x2li - g54) +
                            rec.d5433 * Math.cos(-xomi + x2li - g54)))
            xnddt = xnddt * xldot
          end

          #/* ----------------------- integrator ------------------- */
          #// sgp4fix move end checks to end of routine
          if ((rec.t - rec.atime).abs >= stepp)
            iretn = 381
          else #// exit here
            ft = rec.t - rec.atime
            iretn = 0
          end

          if (iretn == 381)
            rec.xli = rec.xli + xldot * delt + xndt * step2
            rec.xni = rec.xni + xndt * delt + xnddt * step2
            rec.atime = rec.atime + delt
          end
        end
        #}  #// while iretn = 381

        rec.nm = rec.xni + xndt * ft + xnddt * ft * ft * 0.5
        xl = rec.xli + xldot * ft + xndt * ft * ft * 0.5
        if (rec.irez != 1)
          rec.mm = xl - 2.0 * rec.nodem + 2.0 * theta
          rec.dndt = rec.nm - rec.no_unkozai
        else
          rec.mm = xl - rec.nodem - rec.argpm + theta
          rec.dndt = rec.nm - rec.no_unkozai
        end
        rec.nm = rec.no_unkozai + rec.dndt
      end
    end
    #}  // dsspace

    #/*-----------------------------------------------------------------------------
    #*
    #*                           procedure initl
    #*
    #*  this procedure initializes the spg4 propagator. all the initialization is
    #*    consolidated here instead of having multiple loops inside other routines.
    #*  この手順はspg4プロパゲータを初期化します。すべての初期化は他のルーチン内に複数のループを持つ代わりにここに統合されています。
    #*
    #*  author        : david vallado                  719-573-2600   28 jun 2005
    #*
    #*  inputs        :
    #*    satn        - satellite number - not needed, placed in satrec
    #*    xke         - reciprocal of tumin
    #*    j2          - j2 zonal harmonic
    #*    ecco        - eccentricity                           0.0 - 1.0
    #*    epoch       - epoch time in days from jan 0, 1950. 0 hr
    #*    inclo       - inclination of satellite
    #*    no          - mean motion of satellite
    #*
    #*  outputs       :
    #*    ainv        - 1.0 / a
    #*    ao          - semi major axis
    #*    con41       -
    #*    con42       - 1.0 - 5.0 cos(i)
    #*    cosio       - cosine of inclination
    #*    cosio2      - cosio squared
    #*    eccsq       - eccentricity squared
    #*    method      - flag for deep space                    'd', 'n'
    #*    omeosq      - 1.0 - ecco * ecco
    #*    posq        - semi-parameter squared
    #*    rp          - radius of perigee
    #*    rteosq      - square root of (1.0 - ecco*ecco)
    #*    sinio       - sine of inclination
    #*    gsto        - gst at time of observation               rad
    #*    no          - mean motion of satellite
    #*
    #*  locals        :
    #*    ak          -
    #*    d1          -
    #*    del         -
    #*    adel        -
    #*    po          -
    #*
    #*  coupling      :
    #*    getgravconst- no longer used
    #*    gstime      - find greenwich sidereal time from the julian date
    #*
    #*  references    :
    #*    hoots, roehrich, norad spacetrack report #3 1980
    #*    hoots, norad spacetrack report #6 1986
    #*    hoots, schumacher and glover 2004
    #*    vallado, crawford, hujsak, kelso  2006
    #----------------------------------------------------------------------------*/

    def self.initl(epoch, rec)
      #/* --------------------- local variables ------------------------ */
      #double ak, d1, del, adel, po, x2o3

      #// sgp4fix use old way of finding gst
      #double ds70
      #double ts70, tfrac, c1, thgr70, fk5r, c1p2p

      #/* ----------------------- earth constants ---------------------- */
      #// sgp4fix identify constants and allow alternate values
      #// only xke and j2 are used here so pass them in directly
      #// getgravconst( whichconst, tumin, mu, radiusearthkm, xke, j2, j3, j4, j3oj2 )
      x2o3 = 2.0 / 3.0

      #/* ------------- calculate auxillary epoch quantities ---------- */
      rec.eccsq = rec.ecco * rec.ecco
      rec.omeosq = 1.0 - rec.eccsq
      rec.rteosq = Math.sqrt(rec.omeosq)
      rec.cosio = Math.cos(rec.inclo)
      rec.cosio2 = rec.cosio * rec.cosio

      #/* ------------------ un-kozai the mean motion ----------------- */
      ak = (rec.xke / rec.no_kozai) ** x2o3
      d1 = 0.75 * rec.j2 * (3.0 * rec.cosio2 - 1.0) / (rec.rteosq * rec.omeosq)
      ddel = d1 / (ak * ak)
      # del is a keyword in python
      adel = ak * (1.0 - ddel * ddel - ddel * (1.0 / 3.0 + 134.0 * ddel * ddel / 81.0))
      ddel = d1 / (adel * adel)
      rec.no_unkozai = rec.no_kozai / (1.0 + ddel)

      #puts "koz = #{rec.no_kozai}"
      #puts "unkoz = #{rec.no_unkozai}"

      rec.ao = (rec.xke / (rec.no_unkozai)) ** x2o3
      rec.sinio = Math.sin(rec.inclo)
      po = rec.ao * rec.omeosq
      rec.con42 = 1.0 - 5.0 * rec.cosio2
      rec.con41 = -rec.con42 - rec.cosio2 - rec.cosio2
      rec.ainv = 1.0 / rec.ao
      rec.posq = po * po
      rec.rp = rec.ao * (1.0 - rec.ecco)
      rec.method = "n"

      #// sgp4fix modern approach to finding sidereal time
      #//   if (opsmode == 'a')
      #//      {
      #// sgp4fix use old way of finding gst
      #// count integer number of days from 0 jan 1970
      ts70 = epoch - 7305.0
      ds70 = (ts70 + 1.0e-8).floor
      tfrac = ts70 - ds70
      #// find greenwich location at epoch
      c1 = 1.72027916940703639e-2
      thgr70 = 1.7321343856509374
      fk5r = 5.07551419432269442e-15
      c1p2p = c1 + TWOPI
      gsto1 = fmod(thgr70 + c1 * ds70 + c1p2p * tfrac + ts70 * ts70 * fk5r, TWOPI)
      if (gsto1 < 0.0)
        gsto1 = gsto1 + TWOPI
      end
      #//    }
      #//    else
      rec.gsto = gstime(epoch + 2433281.5)
    end
    #}  // initl

    #/*-----------------------------------------------------------------------------
    #*
    #*                             procedure sgp4init
    #*
    #*  this procedure initializes variables for sgp4.
    #*
    #*  author        : david vallado                  719-573-2600   28 jun 2005
    #*
    #*  inputs        :
    #*    opsmode     - mode of operation afspc or improved 'a', 'i'
    #*    whichconst  - which set of constants to use  72, 84
    #*    satn        - satellite number
    #*    bstar       - sgp4 type drag coefficient              kg/m2er
    #*    ecco        - eccentricity
    #*    epoch       - epoch time in days from jan 0, 1950. 0 hr
    #*    argpo       - argument of perigee (output if ds)
    #*    inclo       - inclination
    #*    mo          - mean anomaly (output if ds)
    #*    no          - mean motion
    #*    nodeo       - right ascension of ascending node
    #*
    #*  outputs       :
    #*    satrec      - common values for subsequent calls
    #*    return code - non-zero on error.
    #*                   1 - mean elements, ecc >= 1.0 or ecc < -0.001 or a < 0.95 er
    #*                   2 - mean motion less than 0.0
    #*                   3 - pert elements, ecc < 0.0  or  ecc > 1.0
    #*                   4 - semi-latus rectum < 0.0
    #*                   5 - epoch elements are sub-orbital
    #*                   6 - satellite has decayed
    #*
    #*  locals        :
    #*    cnodm  , snodm  , cosim  , sinim  , cosomm , sinomm
    #*    cc1sq  , cc2    , cc3
    #*    coef   , coef1
    #*    cosio4      -
    #*    day         -
    #*    dndt        -
    #*    em          - eccentricity
    #*    emsq        - eccentricity squared
    #*    eeta        -
    #*    etasq       -
    #*    gam         -
    #*    argpm       - argument of perigee
    #*    nodem       -
    #*    inclm       - inclination
    #*    mm          - mean anomaly
    #*    nm          - mean motion
    #*    perige      - perigee
    #*    pinvsq      -
    #*    psisq       -
    #*    qzms24      -
    #*    rtemsq      -
    #*    s1, s2, s3, s4, s5, s6, s7          -
    #*    sfour       -
    #*    ss1, ss2, ss3, ss4, ss5, ss6, ss7         -
    #*    sz1, sz2, sz3
    #*    sz11, sz12, sz13, sz21, sz22, sz23, sz31, sz32, sz33        -
    #*    tc          -
    #*    temp        -
    #*    temp1, temp2, temp3       -
    #*    tsi         -
    #*    xpidot      -
    #*    xhdot1      -
    #*    z1, z2, z3          -
    #*    z11, z12, z13, z21, z22, z23, z31, z32, z33         -
    #*
    #*  coupling      :
    #*    getgravconst-
    #*    initl       -
    #*    dscom       -
    #*    dpper       -
    #*    dsinit      -
    #*    sgp4        -
    #*
    #*  references    :
    #*    hoots, roehrich, norad spacetrack report #3 1980
    #*    hoots, norad spacetrack report #6 1986
    #*    hoots, schumacher and glover 2004
    #*    vallado, crawford, hujsak, kelso  2006
    #----------------------------------------------------------------------------*/

    def self.sgp4init(opsmode, satrec)
      #/* --------------------- local variables ------------------------ */

      #double cc1sq,
      #  cc2, cc3, coef, coef1, cosio4,
      #  eeta, etasq, perige, pinvsq, psisq, qzms24,
      #        sfour,tc, temp, temp1, temp2, temp3, tsi, xpidot,
      #  xhdot1,qzms2t, ss, x2o3, r[], v[],
      #  delmotemp, qzms2ttemp, qzms24temp

      epoch = (satrec.jdsatepoch + satrec.jdsatepochF) - 2433281.5

      #/* ------------------------ initialization --------------------- */
      #// sgp4fix divisor for divide by zero check on inclination
      #// the old check used 1.0 + cos(pi-1.0e-9), but then compared it to
      #// 1.5 e-12, so the threshold was changed to 1.5e-12 for consistency
      temp4 = 1.5e-12

      #/* ----------- set all near earth variables to zero ------------ */
      satrec.isimp = 0
      satrec.method = "n"
      satrec.aycof = 0.0
      satrec.con41 = 0.0
      satrec.cc1 = 0.0
      satrec.cc4 = 0.0
      satrec.cc5 = 0.0
      satrec.d2 = 0.0
      satrec.d3 = 0.0
      satrec.d4 = 0.0
      satrec.delmo = 0.0
      satrec.eta = 0.0
      satrec.argpdot = 0.0
      satrec.omgcof = 0.0
      satrec.sinmao = 0.0
      satrec.t = 0.0
      satrec.t2cof = 0.0
      satrec.t3cof = 0.0
      satrec.t4cof = 0.0
      satrec.t5cof = 0.0
      satrec.x1mth2 = 0.0
      satrec.x7thm1 = 0.0
      satrec.mdot = 0.0
      satrec.nodedot = 0.0
      satrec.xlcof = 0.0
      satrec.xmcof = 0.0
      satrec.nodecf = 0.0

      #/* ----------- set all deep space variables to zero ------------ */
      satrec.irez = 0
      satrec.d2201 = 0.0
      satrec.d2211 = 0.0
      satrec.d3210 = 0.0
      satrec.d3222 = 0.0
      satrec.d4410 = 0.0
      satrec.d4422 = 0.0
      satrec.d5220 = 0.0
      satrec.d5232 = 0.0
      satrec.d5421 = 0.0
      satrec.d5433 = 0.0
      satrec.dedt = 0.0
      satrec.del1 = 0.0
      satrec.del2 = 0.0
      satrec.del3 = 0.0
      satrec.didt = 0.0
      satrec.dmdt = 0.0
      satrec.dnodt = 0.0
      satrec.domdt = 0.0
      satrec.e3 = 0.0
      satrec.ee2 = 0.0
      satrec.peo = 0.0
      satrec.pgho = 0.0
      satrec.pho = 0.0
      satrec.pinco = 0.0
      satrec.plo = 0.0
      satrec.se2 = 0.0
      satrec.se3 = 0.0
      satrec.sgh2 = 0.0
      satrec.sgh3 = 0.0
      satrec.sgh4 = 0.0
      satrec.sh2 = 0.0
      satrec.sh3 = 0.0
      satrec.si2 = 0.0
      satrec.si3 = 0.0
      satrec.sl2 = 0.0
      satrec.sl3 = 0.0
      satrec.sl4 = 0.0
      satrec.gsto = 0.0
      satrec.xfact = 0.0
      satrec.xgh2 = 0.0
      satrec.xgh3 = 0.0
      satrec.xgh4 = 0.0
      satrec.xh2 = 0.0
      satrec.xh3 = 0.0
      satrec.xi2 = 0.0
      satrec.xi3 = 0.0
      satrec.xl2 = 0.0
      satrec.xl3 = 0.0
      satrec.xl4 = 0.0
      satrec.xlamo = 0.0
      satrec.zmol = 0.0
      satrec.zmos = 0.0
      satrec.atime = 0.0
      satrec.xli = 0.0
      satrec.xni = 0.0

      #/* ------------------------ earth constants ----------------------- */
      #// sgp4fix identify constants and allow alternate values
      #// this is now the only call for the constants
      getgravconst(satrec.whichconst, satrec)

      #//-------------------------------------------------------------------------

      satrec.error = 0
      satrec.operationmode = opsmode

      #// single averaged mean elements
      satrec.am = satrec.em = satrec.im = satrec.Om = satrec.mm = satrec.nm = 0.0

      #/* ------------------------ earth constants ----------------------- */
      #// sgp4fix identify constants and allow alternate values no longer needed
      #// getgravconst( whichconst, tumin, mu, radiusearthkm, xke, j2, j3, j4, j3oj2 )
      ss = 78.0 / satrec.radiusearthkm + 1.0
      #// sgp4fix use multiply for speed instead of pow
      qzms2ttemp = (120.0 - 78.0) / satrec.radiusearthkm
      qzms2t = qzms2ttemp * qzms2ttemp * qzms2ttemp * qzms2ttemp
      x2o3 = 2.0 / 3.0

      satrec.init = "y"
      satrec.t = 0.0

      #// sgp4fix remove satn as it is not needed in initl

      initl(epoch, satrec)

      satrec.a = (satrec.no_unkozai * satrec.tumin) ** (-2.0 / 3.0)
      satrec.alta = satrec.a * (1.0 + satrec.ecco) - 1.0
      satrec.altp = satrec.a * (1.0 - satrec.ecco) - 1.0
      satrec.error = 0

      #// sgp4fix remove this check as it is unnecessary
      #// the mrt check in sgp4 handles decaying satellite cases even if the starting
      #// condition is below the surface of te earth
      #//     if (rp < 1.0)
      #//       {
      #//         satrec.error = 5
      #//       }

      if ((satrec.omeosq >= 0.0) or (satrec.no_unkozai >= 0.0))
        satrec.isimp = 0
        if (satrec.rp < (220.0 / satrec.radiusearthkm + 1.0))
          satrec.isimp = 1
        end
        sfour = ss
        qzms24 = qzms2t
        perige = (satrec.rp - 1.0) * satrec.radiusearthkm

        #/* - for perigees below 156 km, s and qoms2t are altered - */
        if (perige < 156.0)
          sfour = perige - 78.0
          if (perige < 98.0)
            sfour = 20.0
          end
          #// sgp4fix use multiply for speed instead of pow
          qzms24temp = (120.0 - sfour) / satrec.radiusearthkm
          qzms24 = qzms24temp * qzms24temp * qzms24temp * qzms24temp
          sfour = sfour / satrec.radiusearthkm + 1.0
        end

        pinvsq = 1.0 / satrec.posq

        tsi = 1.0 / (satrec.ao - sfour)
        satrec.eta = satrec.ao * satrec.ecco * tsi
        etasq = satrec.eta * satrec.eta
        eeta = satrec.ecco * satrec.eta
        psisq = (1.0 - etasq).abs
        coef = qzms24 * (tsi ** 4.0)
        coef1 = coef / (psisq ** 3.5)
        cc2 = (coef1 * satrec.no_unkozai * (satrec.ao * (1.0 + 1.5 * etasq + eeta *
                                                                             (4.0 + etasq)) + 0.375 * satrec.j2 * tsi / psisq * satrec.con41 *
                                                                                              (8.0 + 3.0 * etasq * (8.0 + etasq))))
        satrec.cc1 = satrec.bstar * cc2
        cc3 = 0.0
        if (satrec.ecco > 1.0e-4)
          cc3 = -2.0 * coef * tsi * satrec.j3oj2 * satrec.no_unkozai * satrec.sinio / satrec.ecco
        end
        satrec.x1mth2 = 1.0 - satrec.cosio2
        satrec.cc4 = (2.0 * satrec.no_unkozai * coef1 * satrec.ao * satrec.omeosq *
                      (satrec.eta * (2.0 + 0.5 * etasq) + satrec.ecco *
                                                          (0.5 + 2.0 * etasq) - satrec.j2 * tsi / (satrec.ao * psisq) *
                                                                                (-3.0 * satrec.con41 * (1.0 - 2.0 * eeta + etasq *
                                                                                                                           (1.5 - 0.5 * eeta)) + 0.75 * satrec.x1mth2 *
                                                                                                                                                 (2.0 * etasq - eeta * (1.0 + etasq)) * Math.cos(2.0 * satrec.argpo))))
        satrec.cc5 = (2.0 * coef1 * satrec.ao * satrec.omeosq * (1.0 + 2.75 *
                                                                       (etasq + eeta) + eeta * etasq))
        cosio4 = satrec.cosio2 * satrec.cosio2
        temp1 = 1.5 * satrec.j2 * pinvsq * satrec.no_unkozai
        temp2 = 0.5 * temp1 * satrec.j2 * pinvsq
        temp3 = -0.46875 * satrec.j4 * pinvsq * pinvsq * satrec.no_unkozai
        satrec.mdot = (satrec.no_unkozai + 0.5 * temp1 * satrec.rteosq * satrec.con41 + 0.0625 *
                                                                                        temp2 * satrec.rteosq * (13.0 - 78.0 * satrec.cosio2 + 137.0 * cosio4))
        satrec.argpdot = (-0.5 * temp1 * satrec.con42 + 0.0625 * temp2 *
                                                        (7.0 - 114.0 * satrec.cosio2 + 395.0 * cosio4) +
                          temp3 * (3.0 - 36.0 * satrec.cosio2 + 49.0 * cosio4))
        xhdot1 = -temp1 * satrec.cosio
        satrec.nodedot = (xhdot1 + (0.5 * temp2 * (4.0 - 19.0 * satrec.cosio2) +
                                    2.0 * temp3 * (3.0 - 7.0 * satrec.cosio2)) * satrec.cosio)
        xpidot = satrec.argpdot + satrec.nodedot
        satrec.omgcof = satrec.bstar * cc3 * Math.cos(satrec.argpo)
        satrec.xmcof = 0.0
        if (satrec.ecco > 1.0e-4)
          satrec.xmcof = -x2o3 * coef * satrec.bstar / eeta
        end
        satrec.nodecf = 3.5 * satrec.omeosq * xhdot1 * satrec.cc1
        satrec.t2cof = 1.5 * satrec.cc1
        #// sgp4fix for divide by zero with xinco = 180 deg
        if ((satrec.cosio + 1.0).abs > 1.5e-12)
          satrec.xlcof = -0.25 * satrec.j3oj2 * satrec.sinio * (3.0 + 5.0 * satrec.cosio) / (1.0 + satrec.cosio)
        else
          satrec.xlcof = -0.25 * satrec.j3oj2 * satrec.sinio * (3.0 + 5.0 * satrec.cosio) / temp4
        end
        satrec.aycof = -0.5 * satrec.j3oj2 * satrec.sinio
        #// sgp4fix use multiply for speed instead of pow
        delmotemp = 1.0 + satrec.eta * Math.cos(satrec.mo)
        satrec.delmo = delmotemp * delmotemp * delmotemp
        satrec.sinmao = Math.sin(satrec.mo)
        satrec.x7thm1 = 7.0 * satrec.cosio2 - 1.0

        #/* --------------- deep space initialization ------------- */
        if ((2 * PI / satrec.no_unkozai) >= 225.0)
          satrec.method = "d"
          satrec.isimp = 1
          tc = 0.0
          satrec.inclm = satrec.inclo

          dscom(epoch, satrec.ecco, satrec.argpo, tc, satrec.inclo, satrec.nodeo, satrec.no_unkozai, satrec)

          satrec.ep = satrec.ecco
          satrec.inclp = satrec.inclo
          satrec.nodep = satrec.nodeo
          satrec.argpp = satrec.argpo
          satrec.mp = satrec.mo

          dpper(satrec.e3, satrec.ee2, satrec.peo, satrec.pgho,
                satrec.pho, satrec.pinco, satrec.plo, satrec.se2,
                satrec.se3, satrec.sgh2, satrec.sgh3, satrec.sgh4,
                satrec.sh2, satrec.sh3, satrec.si2, satrec.si3,
                satrec.sl2, satrec.sl3, satrec.sl4, satrec.t,
                satrec.xgh2, satrec.xgh3, satrec.xgh4, satrec.xh2,
                satrec.xh3, satrec.xi2, satrec.xi3, satrec.xl2,
                satrec.xl3, satrec.xl4, satrec.zmol, satrec.zmos, satrec.init, satrec,
                satrec.operationmode)

          satrec.ecco = satrec.ep
          satrec.inclo = satrec.inclp
          satrec.nodeo = satrec.nodep
          satrec.argpo = satrec.argpp
          satrec.mo = satrec.mp

          satrec.argpm = 0.0
          satrec.nodem = 0.0
          satrec.mm = 0.0

          dsinit(tc, xpidot, satrec)
        end
        #}

        #/* ----------- set variables if not deep space ----------- */
        if (satrec.isimp != 1)
          cc1sq = satrec.cc1 * satrec.cc1
          satrec.d2 = 4.0 * satrec.ao * tsi * cc1sq
          temp = satrec.d2 * tsi * satrec.cc1 / 3.0
          satrec.d3 = (17.0 * satrec.ao + sfour) * temp
          satrec.d4 = 0.5 * temp * satrec.ao * tsi * (221.0 * satrec.ao + 31.0 * sfour) * satrec.cc1
          satrec.t3cof = satrec.d2 + 2.0 * cc1sq
          satrec.t4cof = 0.25 * (3.0 * satrec.d3 + satrec.cc1 * (12.0 * satrec.d2 + 10.0 * cc1sq))
          satrec.t5cof = (0.2 * (3.0 * satrec.d4 +
                                 12.0 * satrec.cc1 * satrec.d3 +
                                 6.0 * satrec.d2 * satrec.d2 +
                                 15.0 * cc1sq * (2.0 * satrec.d2 + cc1sq)))
        end
      end
      #} // if omeosq = 0 ...

      #/* finally propogate to zero epoch to initialize all others. */
      #/ sgp4fix take out check to let satellites process until they are actually below earth surface
      #/       if(satrec.error == 0)

      r = [0, 0, 0]
      v = [0, 0, 0]

      sgp4(satrec, 0.0, r, v)

      satrec.init = "n"

      #/sgp4fix return boolean. satrec.error contains any error codes
      return true
    end
    #  // sgp4init

    #/*-----------------------------------------------------------------------------
    #*
    #*                             procedure sgp4
    #*
    #*  this procedure is the sgp4 prediction model from space command. this is an
    #*    updated and combined version of sgp4 and sdp4, which were originally
    #*    published separately in spacetrack report #3. this version follows the
    #*    methodology from the aiaa paper (2006) describing the history and
    #*    development of the code.
    #*  この手順は、スペースコマンドからのsgp4予測モデルです。これは、元々
    #*  spacetrack report #3で別々に公開されたsgp4とsdp4の更新および統合バージョンです。
    #*  このバージョンは、コードの歴史と開発を説明するaiaa論文（2006）の方法論に従っています。
    #*
    #*  author        : david vallado                  719-573-2600   28 jun 2005
    #*
    #*  inputs        :
    #*    satrec   - initialised structure from sgp4init() call.
    #*    tsince   - time since epoch (minutes)
    #*
    #*  outputs       :
    #*    r           - position vector                     km
    #*    v           - velocity                            km/sec
    #*  return code - non-zero on error.
    #*                   1 - mean elements, ecc >= 1.0 or ecc < -0.001 or a < 0.95 er
    #*                   2 - mean motion less than 0.0
    #*                   3 - pert elements, ecc < 0.0  or  ecc > 1.0
    #*                   4 - semi-latus rectum < 0.0
    #*                   5 - epoch elements are sub-orbital
    #*                   6 - satellite has decayed
    #*
    #*  locals        :
    #*    am          -
    #*    axnl, aynl        -
    #*    betal       -
    #*    cosim   , sinim   , cosomm  , sinomm  , cnod    , snod    , cos2u   ,
    #*    sin2u   , coseo1  , sineo1  , cosi    , sini    , cosip   , sinip   ,
    #*    cosisq  , cossu   , sinsu   , cosu    , sinu
    #*    delm        -
    #*    delomg      -
    #*    dndt        -
    #*    eccm        -
    #*    emsq        -
    #*    ecose       -
    #*    el2         -
    #*    eo1         -
    #*    eccp        -
    #*    esine       -
    #*    argpm       -
    #*    argpp       -
    #*    omgadf      -c
    #*    pl          -
    #*    r           -
    #*    rtemsq      -
    #*    rdotl       -
    #*    rl          -
    #*    rvdot       -
    #*    rvdotl      -
    #*    su          -
    #*    t2  , t3   , t4    , tc
    #*    tem5, temp , temp1 , temp2  , tempa  , tempe  , templ
    #*    u   , ux   , uy    , uz     , vx     , vy     , vz
    #*    inclm       - inclination
    #*    mm          - mean anomaly
    #*    nm          - mean motion
    #*    nodem       - right asc of ascending node
    #*    xinc        -
    #*    xincp       -
    #*    xl          -
    #*    xlm         -
    #*    mp          -
    #*    xmdf        -
    #*    xmx         -
    #*    xmy         -
    #*    nodedf      -
    #*    xnode       -
    #*    nodep       -
    #*    np          -
    #*
    #*  coupling      :
    #*    getgravconst- no longer used. Variables are conatined within satrec
    #*    dpper
    #*    dpspace
    #*
    #*  references    :
    #*    hoots, roehrich, norad spacetrack report #3 1980
    #*    hoots, norad spacetrack report #6 1986
    #*    hoots, schumacher and glover 2004
    #*    vallado, crawford, hujsak, kelso  2006
    #----------------------------------------------------------------------------*/

    def self.sgp4(satrec, tsince, r, v)

      #double axnl, aynl, betal, cnod,
      #  cos2u, coseo1, cosi, cosip, cosisq, cossu, cosu,
      #  delm, delomg, ecose, el2, eo1,
      #  esine, argpdf, pl, mrt = 0.0,
      #  mvt, rdotl, rl, rvdot, rvdotl,
      #  sin2u, sineo1, sini, sinip, sinsu, sinu,
      #  snod, su, t2, t3, t4, tem5, temp,
      #  temp1, temp2, tempa, tempe, templ, u, ux,
      #  uy, uz, vx, vy, vz,
      #  xinc, xincp, xl, xlm,
      #  xmdf, xmx, xmy, nodedf, xnode, tc,
      #  x2o3, vkmpersec, delmtemp

      #int ktr

      #/* ------------------ set mathematical constants --------------- */
      #// sgp4fix divisor for divide by zero check on inclination
      #// the old check used 1.0 + cos(pi-1.0e-9), but then compared it to
      #// 1.5 e-12, so the threshold was changed to 1.5e-12 for consistency
      temp4 = 1.5e-12
      x2o3 = 2.0 / 3.0
      #// sgp4fix identify constants and allow alternate values
      #// getgravconst( whichconst, tumin, mu, radiusearthkm, xke, j2, j3, j4, j3oj2 )
      vkmpersec = satrec.radiusearthkm * satrec.xke / 60.0

      #/* --------------------- clear sgp4 error flag ----------------- */
      satrec.t = tsince
      satrec.error = 0

      #/* ------- update for secular gravity and atmospheric drag ----- */
      xmdf = satrec.mo + satrec.mdot * satrec.t
      argpdf = satrec.argpo + satrec.argpdot * satrec.t
      nodedf = satrec.nodeo + satrec.nodedot * satrec.t
      satrec.argpm = argpdf
      satrec.mm = xmdf
      t2 = satrec.t * satrec.t
      satrec.nodem = nodedf + satrec.nodecf * t2
      tempa = 1.0 - satrec.cc1 * satrec.t
      tempe = satrec.bstar * satrec.cc4 * satrec.t
      templ = satrec.t2cof * t2

      delomg = 0
      delmtemp = 0
      delm = 0
      temp = 0
      t3 = 0
      t4 = 0
      mrt = 0

      if (satrec.isimp != 1)
        delomg = satrec.omgcof * satrec.t
        delmtemp = 1.0 + satrec.eta * Math.cos(xmdf)
        delm = satrec.xmcof * (delmtemp * delmtemp * delmtemp - satrec.delmo)
        temp = delomg + delm
        satrec.mm = xmdf + temp
        satrec.argpm = argpdf - temp
        t3 = t2 * satrec.t
        t4 = t3 * satrec.t
        tempa = tempa - satrec.d2 * t2 - satrec.d3 * t3 - satrec.d4 * t4
        tempe = tempe + satrec.bstar * satrec.cc5 * (Math.sin(satrec.mm) - satrec.sinmao)
        templ = templ + satrec.t3cof * t3 + t4 * (satrec.t4cof + satrec.t * satrec.t5cof)
      end

      tc = 0
      satrec.nm = satrec.no_unkozai
      satrec.em = satrec.ecco
      satrec.inclm = satrec.inclo
      if (satrec.method == "d")
        tc = satrec.t
        dspace(tc, satrec)
      end

      if (satrec.nm <= 0.0)
        satrec.error = 2
        return false
      end

      #puts "nm,xke,tempa = #{satrec.nm}  #{satrec.xke}  #{tempa}"
      satrec.am = ((satrec.xke / satrec.nm) ** x2o3) * tempa * tempa
      satrec.nm = satrec.xke / (satrec.am ** 1.5)
      satrec.em = satrec.em - tempe
      #puts "am,nm,em = #{satrec.am}  #{satrec.nm}  #{satrec.em}"
      if ((satrec.em >= 1.0) or (satrec.em < -0.001))
        satrec.error = 1
        return false
      end

      if (satrec.em < 1.0e-6)
        satrec.em = 1.0e-6
      end

      satrec.mm = satrec.mm + satrec.no_unkozai * templ
      xlm = satrec.mm + satrec.argpm + satrec.nodem
      satrec.emsq = satrec.em * satrec.em
      temp = 1.0 - satrec.emsq

      satrec.nodem = fmod(satrec.nodem, TWOPI)
      satrec.argpm = fmod(satrec.argpm, TWOPI)
      xlm = fmod(xlm, TWOPI)
      satrec.mm = fmod(xlm - satrec.argpm - satrec.nodem, TWOPI)

      satrec.am = satrec.am
      satrec.em = satrec.em
      satrec.im = satrec.inclm
      satrec.Om = satrec.nodem
      satrec.om = satrec.argpm
      satrec.mm = satrec.mm
      satrec.nm = satrec.nm

      # ----------------- compute extra mean quantities -------------
      satrec.sinim = Math.sin(satrec.inclm)
      satrec.cosim = Math.cos(satrec.inclm)

      # -------------------- add lunar-solar periodics --------------
      satrec.ep = satrec.em
      xincp = satrec.inclm
      satrec.inclp = satrec.inclm
      satrec.argpp = satrec.argpm
      satrec.nodep = satrec.nodem
      satrec.mp = satrec.mm
      sinip = satrec.sinim
      cosip = satrec.cosim

      if (satrec.method == "d")
        dpper(satrec.e3, satrec.ee2, satrec.peo, satrec.pgho,
              satrec.pho, satrec.pinco, satrec.plo, satrec.se2,
              satrec.se3, satrec.sgh2, satrec.sgh3, satrec.sgh4,
              satrec.sh2, satrec.sh3, satrec.si2, satrec.si3,
              satrec.sl2, satrec.sl3, satrec.sl4, satrec.t,
              satrec.xgh2, satrec.xgh3, satrec.xgh4, satrec.xh2,
              satrec.xh3, satrec.xi2, satrec.xi3, satrec.xl2,
              satrec.xl3, satrec.xl4, satrec.zmol, satrec.zmos,
              "n", satrec, satrec.operationmode)

        xincp = satrec.inclp
        if (xincp < 0.0)
          xincp = -xincp
          satrec.nodep = satrec.nodep + PI
          satrec.argpp = satrec.argpp - PI
        end

        if ((satrec.ep < 0.0) or (satrec.ep > 1.0))
          satrec.error = 3
          #// sgp4fix add return
          return false
        end
      end
      #} // if method = d

      #/* -------------------- long period periodics ------------------ */
      if (satrec.method == "d")
        sinip = Math.sin(xincp)
        cosip = Math.cos(xincp)
        satrec.aycof = -0.5 * satrec.j3oj2 * sinip
        #// sgp4fix for divide by zero for xincp = 180 deg
        if ((cosip + 1.0).abs > 1.5e-12)
          satrec.xlcof = -0.25 * satrec.j3oj2 * sinip * (3.0 + 5.0 * cosip) / (1.0 + cosip)
        else
          satrec.xlcof = -0.25 * satrec.j3oj2 * sinip * (3.0 + 5.0 * cosip) / temp4
        end
      end

      axnl = satrec.ep * Math.cos(satrec.argpp)
      temp = 1.0 / (satrec.am * (1.0 - satrec.ep * satrec.ep))
      aynl = satrec.ep * Math.sin(satrec.argpp) + temp * satrec.aycof
      xl = satrec.mp + satrec.argpp + satrec.nodep + temp * satrec.xlcof * axnl

      #/* --------------------- solve kepler's equation --------------- */
      u = fmod(xl - satrec.nodep, TWOPI)
      eo1 = u
      tem5 = 9999.9
      ktr = 1
      sineo1 = 0
      coseo1 = 0
      #//   sgp4fix for kepler iteration
      #//   the following iteration needs better limits on corrections
      while ((tem5.abs >= 1.0e-12) and (ktr <= 10))
        sineo1 = Math.sin(eo1)
        coseo1 = Math.cos(eo1)
        tem5 = 1.0 - coseo1 * axnl - sineo1 * aynl
        tem5 = (u - aynl * coseo1 + axnl * sineo1 - eo1) / tem5
        if (tem5.abs >= 0.95)
          if (tem5 > 0)
            tem5 = 0.95
          else
            tem5 = -0.95
          end
          #tem5 = tem5 > 0.0 ? 0.95 : -0.95
        end
        eo1 = eo1 + tem5
        ktr = ktr + 1
      end

      #/* ------------- short period preliminary quantities ----------- */
      ecose = axnl * coseo1 + aynl * sineo1
      esine = axnl * sineo1 - aynl * coseo1
      el2 = axnl * axnl + aynl * aynl
      pl = satrec.am * (1.0 - el2)
      if (pl < 0.0)
        satrec.error = 4
        #// sgp4fix add return
        return false
      else
        rl = satrec.am * (1.0 - ecose)
        rdotl = Math.sqrt(satrec.am) * esine / rl
        rvdotl = Math.sqrt(pl) / rl
        betal = Math.sqrt(1.0 - el2)
        temp = esine / (1.0 + betal)
        sinu = satrec.am / rl * (sineo1 - aynl - axnl * temp)
        cosu = satrec.am / rl * (coseo1 - axnl + aynl * temp)
        su = Math.atan2(sinu, cosu)
        sin2u = (cosu + cosu) * sinu
        cos2u = 1.0 - 2.0 * sinu * sinu
        temp = 1.0 / pl
        temp1 = 0.5 * satrec.j2 * temp
        temp2 = temp1 * temp

        #/* -------------- update for short period periodics ------------ */
        if (satrec.method == "d")
          cosisq = cosip * cosip
          satrec.con41 = 3.0 * cosisq - 1.0
          satrec.x1mth2 = 1.0 - cosisq
          satrec.x7thm1 = 7.0 * cosisq - 1.0
        end

        mrt = rl * (1.0 - 1.5 * temp2 * betal * satrec.con41) + 0.5 * temp1 * satrec.x1mth2 * cos2u
        su = su - 0.25 * temp2 * satrec.x7thm1 * sin2u
        xnode = satrec.nodep + 1.5 * temp2 * cosip * sin2u
        xinc = xincp + 1.5 * temp2 * cosip * sinip * cos2u
        mvt = rdotl - satrec.nm * temp1 * satrec.x1mth2 * sin2u / satrec.xke
        rvdot = rvdotl + satrec.nm * temp1 * (satrec.x1mth2 * cos2u + 1.5 * satrec.con41) / satrec.xke

        #/* --------------------- orientation vectors ------------------- */
        sinsu = Math.sin(su)
        cossu = Math.cos(su)
        snod = Math.sin(xnode)
        cnod = Math.cos(xnode)
        sini = Math.sin(xinc)
        cosi = Math.cos(xinc)
        xmx = -snod * cosi
        xmy = cnod * cosi
        ux = xmx * sinsu + cnod * cossu
        uy = xmy * sinsu + snod * cossu
        uz = sini * sinsu
        vx = xmx * cossu - cnod * sinsu
        vy = xmy * cossu - snod * sinsu
        vz = sini * cossu

        #/* --------- position and velocity (in km and km/sec) ---------- */
        r[0] = (mrt * ux) * satrec.radiusearthkm
        r[1] = (mrt * uy) * satrec.radiusearthkm
        r[2] = (mrt * uz) * satrec.radiusearthkm
        v[0] = (mvt * ux + rvdot * vx) * vkmpersec
        v[1] = (mvt * uy + rvdot * vy) * vkmpersec
        v[2] = (mvt * uz + rvdot * vz) * vkmpersec
      end
      #}  // if pl > 0

      #// sgp4fix for decaying satellites
      if (mrt < 1.0)
        satrec.error = 6
        return false
      end

      return true
    end
    #}  // sgp4

    #/* -----------------------------------------------------------------------------
    #*
    #*                           function getgravconst
    #*
    #*  this function gets constants for the propagator. note that mu is identified to
    #*    facilitiate comparisons with newer models. the common useage is WGS72.
    #*  この関数はプロパゲータのための定数を取得します。muは新しいモデルとの比較を容易にするために識別されています。
    #*    一般的な使用法はWGS72です。
    #*
    #*  author        : david vallado                  719-573-2600   21 jul 2006
    #*
    #*  inputs        :
    #*    whichconst  - which set of constants to use  wgs72old, wgs72, wgs84
    #*
    #*  outputs       :
    #*    tumin       - minutes in one time unit
    #*    mu          - earth gravitational parameter
    #*    radiusearthkm - radius of the earth in km
    #*    xke         - reciprocal of tumin
    #*    j2, j3, j4  - un-normalized zonal harmonic values
    #*    j3oj2       - j3 divided by j2
    #*
    #*  locals        :
    #*
    #*  coupling      :
    #*    none
    #*
    #*  references    :
    #*    norad spacetrack report #3
    #*    vallado, crawford, hujsak, kelso  2006
    #--------------------------------------------------------------------------- */

    def self.getgravconst(whichconst, rec)
      rec.whichconst = whichconst

      #// -- wgs-72 low precision str#3 constants --
      if whichconst == WGS72old
        rec.mu = 398600.79964        #// in km3 / s2
        rec.radiusearthkm = 6378.135    # // km
        rec.xke = 0.0743669161       # // reciprocal of tumin
        rec.tumin = 1.0 / rec.xke
        rec.j2 = 0.001082616
        rec.j3 = -0.00000253881
        rec.j4 = -0.00000165597
        rec.j3oj2 = rec.j3 / rec.j2
        #// ------------ WGS-72 constants ------------
      elsif whichconst == WGS72
        rec.mu = 398600.8            #// in km3 / s2
        rec.radiusearthkm = 6378.135    # // km
        rec.xke = 60.0 / Math.sqrt(rec.radiusearthkm * rec.radiusearthkm * rec.radiusearthkm / rec.mu)
        rec.tumin = 1.0 / rec.xke
        rec.j2 = 0.001082616
        rec.j3 = -0.00000253881
        rec.j4 = -0.00000165597
        rec.j3oj2 = rec.j3 / rec.j2
      else # WGS84
        #// ------------ WGS-84 constants ------------
        rec.mu = 398600.44188          #  // in km3 / s2
        rec.radiusearthkm = 6378.137  #   // km
        rec.xke = 60.0 / Math.sqrt(rec.radiusearthkm * rec.radiusearthkm * rec.radiusearthkm / rec.mu)
        rec.tumin = 1.0 / rec.xke
        rec.j2 = 0.00108262998905
        rec.j3 = -0.00000253215306
        rec.j4 = -0.00000161098761
        rec.j3oj2 = rec.j3 / rec.j2
      end
    end
    #}   // getgravconst

    def self.fmod(numer, denom)
      #return numer%denom
      tquot = (numer / denom).floor
      return numer - tquot * denom
    end

    #/* -----------------------------------------------------------------------------
    #*
    #*                           function gstime
    #*
    #*  this function finds the greenwich sidereal time.
    #*
    #*  author        : david vallado                  719-573-2600    1 mar 2001
    #*
    #*  inputs          description                    range / units
    #*    jdut1       - julian date in ut1             days from 4713 bc
    #*
    #*  outputs       :
    #*    gstime      - greenwich sidereal time        0 to 2pi rad
    #*
    #*  locals        :
    #*    temp        - temporary variable for doubles   rad
    #*    tut1        - julian centuries from the
    #*                  jan 1, 2000 12 h epoch (ut1)
    #*
    #*  coupling      :
    #*    none
    #*
    #*  references    :
    #*    vallado       2013, 187, eq 3-45
    #* --------------------------------------------------------------------------- */

    def self.gstime(jdut1)
      tut1 = (jdut1 - 2451545.0) / 36525.0
      temp = (-6.2e-6 * tut1 * tut1 * tut1 + 0.093104 * tut1 * tut1 +
              (876600.0 * 3600 + 8640184.812866) * tut1 + 67310.54841)  #// sec
      temp = fmod(temp * DEG2RAD / 240.0, TWOPI) #//360/86400 = 1/240, to deg, to rad

      #// ------------------------ check quadrants ---------------------
      if temp < 0.0
        temp += TWOPI
      end

      return temp
    end
    #}  // gstime

    #/* -----------------------------------------------------------------------------
    #*
    #*                           procedure jday
    #*
    #*  this procedure finds the julian date given the year, month, day, and time.
    #*    the julian date is defined by each elapsed day since noon, jan 1, 4713 bc.
    #*
    #*  algorithm     : calculate the answer in one step for efficiency
    #*
    #*  author        : david vallado                  719-573-2600    1 mar 2001
    #*
    #*  inputs          description                    range / units
    #*    year        - year                           1900 .. 2100
    #*    mon         - month                          1 .. 12
    #*    day         - day                            1 .. 28,29,30,31
    #*    hr          - universal time hour            0 .. 23
    #*    min         - universal time min             0 .. 59
    #*    sec         - universal time sec             0.0 .. 59.999
    #*
    #*  outputs       :
    #*    jd          - julian date                    days from 4713 bc
    #*    jdfrac      - julian date fraction into day  days from 4713 bc
    #*
    #*  locals        :
    #*    none.
    #*
    #*  coupling      :
    #*    none.
    #*
    #*  references    :
    #*    vallado       2013, 183, alg 14, ex 3-4
    #* --------------------------------------------------------------------------- */

    def self.jday(year, mon, day, hr, minute, sec)
      jd = 0
      jdFrac = 0

      t1 = ((7 * (year + ((mon + 9) / 12.0).floor)) * 0.25).floor
      t2 = (275 * mon / 9.0).floor

      jd = (367.0 * year - t1 + t2 + day + 1721013.5) # // use - 678987.0 to go to mjd directly

      jdFrac = (sec + minute * 60.0 + hr * 3600.0) / 86400.0

      #// check that the day and fractional day are correct
      if (jdFrac.abs > 1.0)
        dtt = jdFrac.floor
        jd = jd + dtt
        jdFrac = jdFrac - dtt
      end

      return [jd, jdFrac]
    end
  end
end
