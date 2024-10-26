 //Photophysical Properties Analysis


//DialogBox Creation
	
	Dialog.create("Photophysical Analysis");
	Dialog.addMessage("Please choose...                                          ")

	Dialog.addCheckbox("Total On Time ", false);
	Dialog.addCheckbox("Total Photons ", false);
	Dialog.addCheckbox("On Time", false);	
	Dialog.addCheckbox("Number of Blinks", false);	

	Dialog.show();

	totalOnTime=Dialog.getCheckbox();
	totalPhotons=Dialog.getCheckbox();
	OnTime=Dialog.getCheckbox();
	NoOfBlinks=Dialog.getCheckbox();


requires("1.33s"); 
	dir = getDirectory("Choose a Directory ");
	count = 0;
	countFiles(dir);	
	n = 0;
	setBatchMode(true);
	
run("Set Measurements...", "area mean standard min redirect=None decimal=2");
	processFiles(dir);
	//print(count+" files processed");
   
function countFiles(dir) 
	{
      list = getFileList(dir);
      for (i=0; i<list.length; i++) 
		{
  		if (!startsWith(list[i],"Log"))
			{
        		if (endsWith(list[i], "/"))
             	countFiles(""+dir+list[i]);
          		else
              	count++;
    			  }
  		}
	}	
function processFiles(dir) 
	{
      list = getFileList(dir);
      for (i=0; i<list.length; i++) 
		{
		if (!startsWith(list[i],"Log"))
			{
          		if (endsWith(list[i], "/"))
              	processFiles(""+dir+list[i]);
          		else 
				{
             		showProgress(n++, count);
             		path = dir+list[i];
             		processFile(path);
          			}
			}
      	}
	}


function processFile(path)
	{
      if (endsWith(path, ".tif") || endsWith(path, ".tiff")) 
		{
       	open(path);
		file= getTitle();				// image filename.tif 
		root = substring(file,0,indexOf(file, ".tif"));		// image rootname
		}	// End batch processing loop


//Start of Blinking code

setBatchMode(false);

	title= getTitle();				// image filename.tif 
	root = substring(title,0,indexOf(title, ".tif"));		// image rootname
	
	FilePath= File.getAbsolutePath(title);
	File.makeDirectory(dir+"\\ImagingAnalysis_"+title);
	File.makeDirectory(dir+"\\Imaging");
	File.makeDirectory(dir+"\\Imaging\\Analysis_"+title);
	File.makeDirectory(dir+"Analysis_txt"+title);
	SaveTemp=(dir+"Analysis_"+title);
	
	//print(SaveTemp);
	//print(FilePath);
	//print(dir+"Analysis_"+title);

	



	// Choose analysis
	//
	//onoffBlinking=false;
	//totalPhotons=false;
	//DutyCycle=true;
	//
	//



	if(totalPhotons==true)//Outputs integrated intensity under single spot, background and intensity above background
		{	
			
		//makeRectangle(0, 0, 512, 512);//can crop image area to analyse
		//run("Crop");
		//run("Z Project...", "stop=120 projection=[Sum Slices]");
		//run("Z Project...", "stop=5 projection=Median");
		//medImage=getTitle();
		selectWindow(title);
		run("Z Project...", "projection=[Max Intensity]");
		sumImage=getTitle();
		selectWindow(sumImage);
		run("Find Maxima...", "prominence=20 strict output=List");
		saveAs("Results", ""+dir+"Analysis_txt"+title+"\\"+title+"_MaximaforSum.txt");//saves maxima, can comment out 
		text = File.openAsString(""+dir+"Analysis_txt"+title+"\\"+title+"_MaximaforSum.txt");
 		//Remember when finding maxima, select list output, or will not work
		lines=split(text, "\n");
		
		setBatchMode(true);
		print("x,y,totalSignal,Background,Signal,NoiseSig,NoiseBck,SNRsig,SNRbck");

		for (i=1; i<lines.length; i++) 
			{
			selectWindow(sumImage);
			items=split(lines[i], ",\t");
			x = parseInt(items[1]);
			y = parseInt(items[2]);
			selectWindow(sumImage);
			SquareSize=3;
			makeRectangle((x-1), (y-1), SquareSize, SquareSize);
			run("Set Measurements...", "area mean standard min integrated redirect=None decimal=2");
			run("Measure");
			totalSignal=getResult("IntDen");
			maxSignal=getResult("Max");
			Mean=getResult("Mean");
			NoiseSig=getResult("StdDev");
			NoiseBck=getResult("StdDev");
			Background=maxSignal;
			//background determination
			
		
			totalArea=getResult("Area");
			makeRectangle((x+SquareSize), y-1, SquareSize, SquareSize);
			run("Measure");
			Background1=getResult("IntDen");
			Background1n=getResult("StdDev");
			BackgroundArea=getResult("Area");
			MinArea=SquareSize*SquareSize;

			if(BackgroundArea==MinArea)
				{
				makeRectangle((x-SquareSize), y-1, SquareSize, SquareSize);
				run("Measure");
				Background2=getResult("IntDen");
				Background2n=getResult("StdDev");
				Area2=getResult("Area");	
				
				makeRectangle(x-1, (y+SquareSize), SquareSize, SquareSize);
				run("Measure");
				Background3=getResult("IntDen");
				Background3n=getResult("StdDev");
				Area3=getResult("Area");	
				
				makeRectangle(x-1, (y-SquareSize), SquareSize, SquareSize);
				run("Measure");
				Background4=getResult("IntDen");
				Background4n=getResult("StdDev");
				Area4=getResult("Area");	
				
				Bckgd = newArray(Background1, Background2, Background3, Background4);								
				Bckgdn = newArray(Background1n, Background2n, Background3n, Background4n);
				
				Array.getStatistics(Bckgd,min,max,mean,stdDev);
				Background = min;
				Array.getStatistics(Bckgd,min,max,mean,stdDev);
				NoiseBck = max;
					

				}//minArea Loop//
		
	
		Signal=totalSignal-Background;
		SNRsig=Mean/NoiseSig;
		SNRbck=Mean/NoiseBck;

		print(""+x+","+y+","+totalSignal+","+Background+","+Signal+","+NoiseSig+","+NoiseBck+","+SNRsig+","+SNRbck+"");

		}//i loop//

		//closing images
		//selectWindow(title);
		//run("Close");
		selectWindow(sumImage);
		saveAs("Tiff", ""+dir+"Imaging\\Analysis_"+title+"\\"+title+"_SumProject");
		run("Close");

		//Save data
		selectWindow("Log");
		saveAs("Text", ""+dir+"Analysis_txt"+title+"\\"+title+"_PhotonLog.txt");		
		

		}//MaxPropjection loop//


if (totalOnTime==true)//Outputs the time a single molecule is fluorescent for during acquisition
	{
	//makeRectangle(0, 0, 512, 512);
	//run("Crop");
	run("Z Project...", "projection=[Max Intensity]");
	//zTitle=getTitle();
	saveAs("Tiff", ""+dir+"Analysis_txt"+title+"\\"+title+"_zProject");
	zTitle=getTitle();

	run("Enhance Contrast", "saturated=0.35");
	run("Gaussian Blur...", "sigma=1");
	run("Find Maxima...", "noise=150 output=List"); //Can change the noise tolerance for your data
	saveAs("Results", ""+dir+"Analysis_txt"+title+"\\"+title+"_Maxima.txt");
	text = File.openAsString(""+dir+"Analysis_txt"+title+"\\"+title+"_Maxima.txt");
 	//Remember when finding maxima, select list output, or will not work
	lines=split(text, "\n");

	run("Tile");
	
	setBatchMode(true);

		for (i=1; i<lines.length; i++) 
			{
			items=split(lines[i], ",\t");
			x = parseInt(items[1]);
			y = parseInt(items[2]);
			selectWindow(title);
			setSlice(1);
			OvalSize=14;
			makeOval((x-(OvalSize/2)), (y-(OvalSize/2)), OvalSize, OvalSize);
			run("Duplicate...", "title="+x+","+y+" duplicate range=1-"+nSlices+"");
			saveAs("Tiff", ""+dir+"Imaging\\Analysis_"+title+"\\"+title+"_Position_"+x+","+y+"");
			title4=getTitle();
		
			run("Scale...", "x=- y=- z=1.0 width=1 height=1 depth=nSlices interpolation=Bilinear average process create title=Row1Well1_1-3.tif");
 
			//run("Scale...", "x=- y=- z=1.0 width=1 height=1 depth=250 interpolation=Bilinear average process title=Row1Well1_1-3.tif");
			
		
			title3=getTitle();
		
			run("Reslice [/]...", "output=1.000 start=Top rotate avoid");
			saveAs("Tiff", ""+dir+"Imaging\\Analysis_"+title+"\\"+title+"_Position_Reslice"+x+","+y+"");
			title5=getTitle();
		
			totTime=getWidth();
			run("Set Measurements...", "mean standard min redirect=None decimal=2");
			run("Measure");
		
			minPix=getResult("Min");
			maxPix=getResult("Max");

			Threshold=round(((maxPix-minPix)/2)+minPix);//can change this
			//print(Threshold);

			setThreshold(Threshold, maxPix);
		
			run("Set Measurements...", "area mean limit standard min redirect=None decimal=2");
			run("Select All");
			run("Measure");
			OnTime=getResult("Area");

			//OnOffRatio=OnTime/totTime;
		
		
			print(""+x+","+y+","+Threshold+","+OnTime+","+totTime+"");

			}//closes i loop

			selectWindow(zTitle);
			setColor (64000);
			fillOval((x-(OvalSize/2)), (y-(OvalSize/2)), OvalSize, OvalSize);

			selectWindow(title3);
			run("Close");
		
			selectWindow(title4);
			run("Close");
		
			selectWindow(title5);
			run("Close");

		}//Closes onoffblinking code		


	
		if(OnTime==true)//Outputs the time per 'on' blinking event for single molecule
			{
			//makeRectangle(0, 0, 512, 512);
			//run("Crop");
			run("Z Project...", "projection=[Max Intensity]");
			//zTitle=getTitle();
			saveAs("Tiff", ""+dir+"Analysis_txt"+title+"\\"+title+"_zProject");
			zTitle=getTitle();

			run("Enhance Contrast", "saturated=0.35");
			run("Gaussian Blur...", "sigma=1");
			run("Find Maxima...", "noise=25 output=List"); //Can change the noise tolerance for your data
			saveAs("Results", ""+dir+"Analysis_txt"+title+"\\"+title+"_Maxima.txt");
			text = File.openAsString(""+dir+"Analysis_txt"+title+"\\"+title+"_Maxima.txt");
 			//Remember when finding maxima, select list output, or will not work
			lines=split(text, "\n");

			run("Tile");
	
			setBatchMode(true);

			for (i=1; i<lines.length; i++) 
			{
				items=split(lines[i], ",\t");
				x = parseInt(items[1]);
				y = parseInt(items[2]);
				selectWindow(title);
				setSlice(1);
				OvalSize=4;
				makeOval((x-(OvalSize/2)), (y-(OvalSize/2)), OvalSize, OvalSize);
				run("Duplicate...", "title="+x+","+y+" duplicate range=1-"+nSlices+"");
				saveAs("Tiff", ""+dir+"Imaging\\Analysis_"+title+"\\"+title+"_Position_"+x+","+y+"");
				title4=getTitle();
		
				run("Scale...", "x=- y=- z=1.0 width=1 height=1 depth=nSlices interpolation=Bilinear average process create title=Row1Well1_1-3.tif");
 
		
				title3=getTitle();
		
				run("Reslice [/]...", "output=1.000 start=Top rotate avoid");
				saveAs("Tiff", ""+dir+"Imaging\\Analysis_"+title+"\\"+title+"_Position_Reslice"+x+","+y+"");
				title5=getTitle();
		
				totTime=getWidth();
				run("Set Measurements...", "mean standard min redirect=None decimal=2");
				run("Measure");
		
				minPix=getResult("Min");
				maxPix=getResult("Max");

				Threshold=round(((maxPix-minPix)/2)+minPix);
				//print(Threshold);

				setThreshold(Threshold, maxPix);
		
				
				//start duty cycle code
			
				selectWindow(title5);
				resliceWidth=getWidth();
				DutyCounter=1;
				//NumberofBlinks=0;

				for (q=0; q<resliceWidth-1; q++) 
					{
					//NumberofBlinks=0;
					DutyPixel=getPixel(q,0);
					if (DutyPixel>Threshold)
							{
							DutyPixelPlusOne=getPixel(q+1,0);
							if (DutyPixelPlusOne>Threshold)
								{
								DutyCounter=DutyCounter+1;
								}
						
							if(DutyPixelPlusOne<=Threshold)								
								{
								print(DutyCounter);
								DutyCounter=1;
								//NumberofBlinks=NumberofBlinks+1;
								}
							}
					
					}//closes q loop

			
		//print("NumberofBlinks"+NumberofBlinks+"");	
		selectWindow(zTitle);
		setColor (64000);
		fillOval((x-(OvalSize/2)), (y-(OvalSize/2)), OvalSize, OvalSize);

		}//closes i loop

		selectWindow(title3);
		run("Close");
		
		selectWindow(title4);
		run("Close");
		
		selectWindow(title5);
		run("Close");
		
		//selectWindow("Log");		
		//saveAs("Text", ""+dir+"Analysis_txt"+title+"\\"+title+"_DutyCycleLog.txt");
		//run("Close");

		}//close DutyCycleloop




if(NoOfBlinks==true)	//Outputs the number of blinking events per single molecule

		{
			makeRectangle(0, 0, 512, 512);
			run("Crop");
			run("Z Project...", "projection=[Max Intensity]");
			//zTitle=getTitle();
			saveAs("Tiff", ""+dir+"Analysis_txt"+title+"\\"+title+"_zProject");
			zTitle=getTitle();

			run("Enhance Contrast", "saturated=0.35");
			run("Gaussian Blur...", "sigma=1");
			run("Find Maxima...", "noise=5000 output=List"); //Can change the noise tolerance for your data
			saveAs("Results", ""+dir+"Analysis_txt"+title+"\\"+title+"_Maxima.txt");
			text = File.openAsString(""+dir+"Analysis_txt"+title+"\\"+title+"_Maxima.txt");
 			//Remember when finding maxima, select list output, or will not work
			lines=split(text, "\n");

			run("Tile");
	
			setBatchMode(true);

			for (i=1; i<lines.length; i++) 
			{
				items=split(lines[i], ",\t");
				x = parseInt(items[1]);
				y = parseInt(items[2]);
				selectWindow(title);
				setSlice(1);
				OvalSize=4;
				makeOval((x-(OvalSize/2)), (y-(OvalSize/2)), OvalSize, OvalSize);
				run("Duplicate...", "title="+x+","+y+" duplicate range=1-"+nSlices+"");
				saveAs("Tiff", ""+dir+"Imaging\\Analysis_"+title+"\\"+title+"_Position_"+x+","+y+"");
				title4=getTitle();
		
				run("Scale...", "x=- y=- z=1.0 width=1 height=1 depth=nSlices interpolation=Bilinear average process create title=Row1Well1_1-3.tif");
 
				//run("Scale...", "x=- y=- z=1.0 width=1 height=1 depth=250 interpolation=Bilinear average process title=Row1Well1_1-3.tif");
			
		
				title3=getTitle();
		
				run("Reslice [/]...", "output=1.000 start=Top rotate avoid");
				saveAs("Tiff", ""+dir+"Imaging\\Analysis_"+title+"\\"+title+"_Position_Reslice"+x+","+y+"");
				title5=getTitle();
		
				totTime=getWidth();
				run("Set Measurements...", "mean standard min redirect=None decimal=2");
				run("Measure");
		
				minPix=getResult("Min");
				maxPix=getResult("Max");

				Threshold=round(((maxPix-minPix)/2)+minPix);
				//print(Threshold);

				setThreshold(Threshold, maxPix);
		
				
				//start duty cycle code
			
				selectWindow(title5);
				resliceWidth=getWidth();
	
				DutyCounter=1;

				NumberofBlinks=0;

				for (q=0; q<resliceWidth-1; q++) 
					{
					//NumberofBlinks=0;
					DutyPixel=getPixel(q,0);
					if (DutyPixel>Threshold)
							{
							DutyPixelPlusOne=getPixel(q+1,0);
							//DutyPixelPlustwo=getPixel(q+2,0);
							//DutyPixelPlusthree=getPixel(q+3,0);
							if (DutyPixelPlusOne>Threshold)
								{
								DutyCounter=DutyCounter+1;
								}
						
							if(DutyPixelPlusOne<=Threshold)								
								{
								//print(DutyCounter);
								DutyCounter=1;
								NumberofBlinks=NumberofBlinks+1;
								}
							}
					
					}//closes q loop

			
		//print("NumberofBlinks = "+NumberofBlinks+"");	
		print(NumberofBlinks);	
		selectWindow(zTitle);
		setColor (64000);
		fillOval((x-(OvalSize/2)), (y-(OvalSize/2)), OvalSize, OvalSize);

		}//closes i loop

		selectWindow(title3);
		run("Close");
		
		selectWindow(title4);
		run("Close");
		
		selectWindow(title5);
		run("Close");
		
		//selectWindow("Log");		
		//saveAs("Text", ""+dir+"Analysis_txt"+title+"\\"+title+"_DutyCycleLog.txt");
		//run("Close");

		


		}//Close Number of Blinks loop


if (totalOnTime==true)
	{
	selectWindow(zTitle);
	saveAs("Tiff", ""+dir+"Analysis_txt"+title+"\\"+title+"_zProject_Holes");
	run("Close");	
	}
	

if (OnTime==true)
	{
	selectWindow(zTitle);
	saveAs("Tiff", ""+dir+"Analysis_txt"+title+"\\"+title+"_zProject_Holes");
	run("Close");	
	}

if (NoOfBlinks==true)
	{
	selectWindow(zTitle);
	saveAs("Tiff", ""+dir+"Analysis_txt"+title+"\\"+title+"_zProject_Holes");
	run("Close");	
	//run("Close All");
	}




selectWindow(title);
run("Close");

selectWindow("Log");
//saveAs("Tiff", ""+dir+"Analysis_txt"+title+"\\"+title+"_zProject");
//run("Text...", ""+dir+"Analysis_txt"+title+"\\"+title+"_Log.txt");

if (totalOnTime==true)
saveAs("Text", ""+dir+"Analysis_txt"+title+"\\TotalOnTime.txt");

if (totalPhotons==true)
saveAs("Text", ""+dir+"Analysis_txt"+title+"\\TotalPhotonLog.txt");

if (OnTime==true)
saveAs("Text", ""+dir+"Analysis_txt"+title+"\\OnTime.txt");

if (NoOfBlinks==true)
saveAs("Text", ""+dir+"Analysis_txt"+title+"\\TotalNumberofBlinksLog.txt");

selectWindow("Log");
run("Close");

//run("Close All");
	}

	//print("Finished!");
	

