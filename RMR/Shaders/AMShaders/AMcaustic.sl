slim 1 appearance slim {
instance surface "AMcaustic" "The_search_path_to_Amcaustics.slo" {
 description {The idea is that you apply this shader to a NURBs plane, witch by someway mimics the translation and size of the caustic. The shader will then alter the colour and opacity of  the plane to mimic a caustic being casted on a surface. The shader will create a round caustic centred on the plane. But don't be afraid to "warp" the caustic by manipulating the CVs of your plane! The caustic is built up by 2 parts, noise Caustic (Nc) and radial caustic (Rc). Only where there is white in both the caustic will be visible. Get it?}
  previewinfo {
    shadingrate 5
    objectsize 1
    objectshape Plane
    frame 1
  }
  parameter float OverallStrength {
    default .5
    value 1.00
    range {0 1}
    subtype slider
    detail varying {}
description {The opacity of the caustic.}
  }
    parameter color CausticColour {
    default {0 .25 1}
    value {1 1 1}
    detail varying {}
description {The colour (tint) of the caustic}
  }
  parameter float NcRamp1 {
    default 1
    value 0.185714285714
    range {0 1}
    subtype slider
description {This, and the fallowing tow parameters controls the gradient of witch the noise is made from. Pulling the first and last one closer to itch other makes the contrast in the caustic noise to increase. Experiment! Its basically like "levels" in PhotoShop. Normally you whant to keep this number low, NcRamp3 hi and NcRamp2 in the middle!}
  }
  parameter float NcRamp2 {
    default 1
    value 0.8
    range {0 1}
    subtype slider

  }
  parameter float NcRamp3 {
    default 0
    value 0.95
    range {0 1}
    subtype slider

  }

  parameter float NcDetail {
    default 4
    value 2
    range {1 8 1}
    subtype slider
    description {A integer value (no decimals) for how detailed you whant your caustic.}
  }
  parameter float NcContrast {
    default .5
    value 1.15
    range {0 4 .01}
    subtype slider
    description {Bumps up the contrast of the fractal, resulting in a sharper, somewhat mor intensive looking caustic.}
  }
    parameter float NcScale {
    default 2
    value 2.0
    range {1 4 .01}
    subtype slider
    description {Scales the noise caustic fractal}
  }

    parameter float NcTimeOffset {
    default 0
description {If your not satisfide whith the way your noise caustic fractal looks you can modify this number. Or if you have NcTimeScale on (not 0) you can offset the animation of the fractal. OK?}
  }
    parameter float NcTimeScale {
    default 1
    value 0.000
description {If you whant to simulate caustics from say a swimming pool, set this to a non zero value, and the fractal will animate!Higher values means faster animation.}
  }
    parameter float RcRamp1p {
    default 1
    value 0.432142857143
    range {0 1}
    subtype slider
description {Intruducing the radial caustic! The following parameters represent a gradiant.This parameter represents the position of the first value (the value closest ts the edge). The parameter under this oune (RcRamp1c) is this positions colour value. The one underneth that (rCRamp2p) is the position of the second knot in the cradient Underneath that, its colour Then another position and colour. And so on...}
  }
  parameter color RcRamp1c {
    default {1 1 1}
    value {0.352941176471 0.352941176471 0.352941176471}
    detail varying {}

  }
  parameter float RcRamp2p {
    default 0
    value 0.517857142857
    range {0 1}
    subtype slider

  }
  parameter color RcRamp2c {
    default {0 0 0}
    value {1.0 1.0 1.0}
    detail varying {}

  }
  parameter float RcRamp3p {
    default 0
    value 0.632142857143
    range {0 1}
    subtype slider

  }
    parameter color RcRamp3c {
    default {0 0 0}
    value {0.392156862745 0.392156862745 0.392156862745}
    detail varying {}

  }
    parameter float RcRamp4p {
    default 0
    value 0.853571428571
    range {0 1}
    subtype slider

  }
    parameter color RcRamp4c {
    default {0 0 0}
    value {0.266666666667 0.266666666667 0.266666666667}
    detail varying {}


  }
    parameter float RcRamp5p {
    default 0
    value 1.00
    range {0 1}
    subtype slider
description {Hope you enjoy this shader!}
  }
    parameter color RcRamp5c {
    default {0 0 0}
    value {1.0 1.0 1.0}
    detail varying {}
description {Aron Makkai aron3 AT yahoo DOT com }
  }

}
}

