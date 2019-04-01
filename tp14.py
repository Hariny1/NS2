import os.path

packet = 0
start = 400.00
end = 0.00

packet1 = 0
start1 = 400.00
end1 = 0.00

fp=open('out.tr','r')
fp1=open('out1.xg','w')
fp2=open('out2.xg','w')

for line in fp:
	t = line.split()
	if len(t) != 0 and t[4]=='tcp':
		event = t[0]
		time = float(t[1])
		send = int(t[2])
		recv = int(t[3])
		level = t[4]
		size = int(t[5])
	
		if size >= 512:
			if (send == 0 and recv == 2):
				if event == "+" and time < start:
					start = time
				if event == "r" and time > end:
					end = time
					size -= size % 512
					packet += size
					print >> fp1,round(time,2),"\t",round(packet/(end-start)*(8/float(1000)),2)
			elif (send == 7 and recv == 4) :
				if event == "+" and time < start1:
					start1 = time
				if event == "r" and time > end1:
					end1 = time
					size -= size % 512
					packet1 += size
					print >> fp2,round(time,2),"\t",round(packet1/(end1-start1)*(8/float(1000)),2)

print "\nAverage Throughput:" , round(packet/(end-start)*(8/float(1000)),2) , "Kbps"
print "Packet-Size:" , packet
print "Start-Time:" , round(start,2)
print "End-Time:" , round(end,2)

print "\nAverage Throughput:" , round(packet1/(end1-start1)*(8/float(1000)),2) , "Kbps"
print "Packet-Size:" , packet1
print "Start-Time:" , round(start1,2)
print "End-Time:" , round(end1,2)

fp.close()
fp1.close()
fp2.close()

os.system('xgraph out1.xg out2.xg -x Time -y Packets')
