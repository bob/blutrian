require File.expand_path('../../trian_funcs', __FILE__)
#require_relative '../trian_funcs'

describe TrianFuncs do
  before(:each) do
    @ap1 = [74,26]; @ap2 = [10,8]; @ap3 = [9,68]
    aps = [@ap1, @ap2, @ap3]
    @trian = TrianFuncs.new(aps)
  end

  context "#process" do
    it "for inner point" do
      a = 44; b = 59; c = 62
      ox, oy = @trian.process(a, b, c)

      expect(ox.to_s).to eq '44.4931575980041'
      expect(oy.to_s).to eq '39.3319026723307'
    end

  end

  context "#discover_angles" do

    it "process inner point" do
      fls1 = 107.609436725129; fls2 = 97.129417480387; fls3 = 125.261145794484
      a = 44; b = 59; c = 62
      ang1, ang2, ang3 = @trian.discover_angles([a, b, c], [fls1, fls2, fls3])

      expect(ang1.to_s).to eq '115.575986467115'
      expect(ang2.to_s).to eq '79.0395047947747'
      expect(ang3.to_s).to eq '165.386521571667'
    end

    context "process outer point" do
      it "First side" do
        fls2 = 114.783399173471; fls3 = 103.604711979079; fls1 = 133.61188884745
        a = 64; b = 44; c = 68

        ang1, ang2, ang3 = @trian.discover_angles([a, b, c], [fls1, fls2, fls3])
        expect(ang2.to_s).to eq '103.311751023685'
        expect(ang3.to_s).to eq '72.280388485431'
        expect(ang1.to_s).to eq '184.406779258533'
      end

      it "Second side" do
        fls3 = 114.783399173471; fls1 = 103.604711979079; fls2 = 133.61188884745
        a = 68; b = 64; c = 44

        ang1, ang2, ang3 = @trian.discover_angles([a, b, c], [fls1, fls2, fls3])
        expect(ang3.to_s).to eq '103.311751023685'
        expect(ang1.to_s).to eq '72.280388485431'
        expect(ang2.to_s).to eq '184.406779258533'
      end

      it "Third side" do
        fls1 = 114.783399173471; fls2 = 103.604711979079; fls3 = 133.61188884745
        a = 44; b = 68; c = 64

        ang1, ang2, ang3 = @trian.discover_angles([a, b, c], [fls1, fls2, fls3])
        expect(ang1.to_s).to eq '103.311751023685'
        expect(ang2.to_s).to eq '72.280388485431'
        expect(ang3.to_s).to eq '184.406779258533'
      end

      it "Error 1" do
        fls1 = 114.783399173471; fls2 = 103.604711979079; fls3 = 133.61188884745
        a = 45; b = 74; c = 57

        ang1, ang2, ang3 = @trian.discover_angles([a, b, c], [fls1, fls2, fls3])
      end

    end


  end
end
