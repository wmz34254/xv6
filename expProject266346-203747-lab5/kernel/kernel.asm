
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0011a117          	auipc	sp,0x11a
    80000004:	de010113          	addi	sp,sp,-544 # 80119de0 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	1b9050ef          	jal	ra,800059ce <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <kfree>:
//   kmem.freelist = r;
//   release(&kmem.lock);
// }

void kfree(void *pa)
{
    8000001c:	7179                	addi	sp,sp,-48
    8000001e:	f406                	sd	ra,40(sp)
    80000020:	f022                	sd	s0,32(sp)
    80000022:	ec26                	sd	s1,24(sp)
    80000024:	e84a                	sd	s2,16(sp)
    80000026:	e44e                	sd	s3,8(sp)
    80000028:	1800                	addi	s0,sp,48
  struct run *r;

  if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    8000002a:	03451793          	slli	a5,a0,0x34
    8000002e:	efa1                	bnez	a5,80000086 <kfree+0x6a>
    80000030:	84aa                	mv	s1,a0
    80000032:	00122797          	auipc	a5,0x122
    80000036:	eae78793          	addi	a5,a5,-338 # 80121ee0 <end>
    8000003a:	04f56663          	bltu	a0,a5,80000086 <kfree+0x6a>
    8000003e:	47c5                	li	a5,17
    80000040:	07ee                	slli	a5,a5,0x1b
    80000042:	04f57263          	bgeu	a0,a5,80000086 <kfree+0x6a>
    panic("kfree");
  acquire(&phypgrefer[PG_IDX((uint64)pa)].lock);
    80000046:	80000937          	lui	s2,0x80000
    8000004a:	992a                	add	s2,s2,a0
    8000004c:	00c95913          	srli	s2,s2,0xc
    80000050:	00591993          	slli	s3,s2,0x5
    80000054:	00009797          	auipc	a5,0x9
    80000058:	8fc78793          	addi	a5,a5,-1796 # 80008950 <phypgrefer>
    8000005c:	99be                	add	s3,s3,a5
    8000005e:	854e                	mv	a0,s3
    80000060:	00006097          	auipc	ra,0x6
    80000064:	35a080e7          	jalr	858(ra) # 800063ba <acquire>
  if (phypgrefer[PG_IDX((uint64)pa)].count > 0)
    80000068:	0189c783          	lbu	a5,24(s3)
    8000006c:	c78d                	beqz	a5,80000096 <kfree+0x7a>
    phypgrefer[PG_IDX((uint64)pa)].count -= 1;
    8000006e:	37fd                	addiw	a5,a5,-1
    80000070:	0ff7f793          	andi	a5,a5,255
    80000074:	00f98c23          	sb	a5,24(s3)
  if (phypgrefer[PG_IDX((uint64)pa)].count != 0)// 当此物理地址没有逻辑地址引用时才可以释放该物理地址
    80000078:	cf99                	beqz	a5,80000096 <kfree+0x7a>
  {
    release(&phypgrefer[PG_IDX((uint64)pa)].lock);
    8000007a:	854e                	mv	a0,s3
    8000007c:	00006097          	auipc	ra,0x6
    80000080:	3f2080e7          	jalr	1010(ra) # 8000646e <release>
    return;
    80000084:	a881                	j	800000d4 <kfree+0xb8>
    panic("kfree");
    80000086:	00008517          	auipc	a0,0x8
    8000008a:	f8a50513          	addi	a0,a0,-118 # 80008010 <etext+0x10>
    8000008e:	00006097          	auipc	ra,0x6
    80000092:	df0080e7          	jalr	-528(ra) # 80005e7e <panic>
  }
  release(&phypgrefer[PG_IDX((uint64)pa)].lock);
    80000096:	854e                	mv	a0,s3
    80000098:	00006097          	auipc	ra,0x6
    8000009c:	3d6080e7          	jalr	982(ra) # 8000646e <release>

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    800000a0:	6605                	lui	a2,0x1
    800000a2:	4585                	li	a1,1
    800000a4:	8526                	mv	a0,s1
    800000a6:	00000097          	auipc	ra,0x0
    800000aa:	220080e7          	jalr	544(ra) # 800002c6 <memset>

  r = (struct run *)pa;

  acquire(&kmem.lock);
    800000ae:	00009917          	auipc	s2,0x9
    800000b2:	88290913          	addi	s2,s2,-1918 # 80008930 <kmem>
    800000b6:	854a                	mv	a0,s2
    800000b8:	00006097          	auipc	ra,0x6
    800000bc:	302080e7          	jalr	770(ra) # 800063ba <acquire>
  r->next = kmem.freelist;
    800000c0:	01893783          	ld	a5,24(s2)
    800000c4:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    800000c6:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    800000ca:	854a                	mv	a0,s2
    800000cc:	00006097          	auipc	ra,0x6
    800000d0:	3a2080e7          	jalr	930(ra) # 8000646e <release>
}
    800000d4:	70a2                	ld	ra,40(sp)
    800000d6:	7402                	ld	s0,32(sp)
    800000d8:	64e2                	ld	s1,24(sp)
    800000da:	6942                	ld	s2,16(sp)
    800000dc:	69a2                	ld	s3,8(sp)
    800000de:	6145                	addi	sp,sp,48
    800000e0:	8082                	ret

00000000800000e2 <freerange>:
{
    800000e2:	7139                	addi	sp,sp,-64
    800000e4:	fc06                	sd	ra,56(sp)
    800000e6:	f822                	sd	s0,48(sp)
    800000e8:	f426                	sd	s1,40(sp)
    800000ea:	f04a                	sd	s2,32(sp)
    800000ec:	ec4e                	sd	s3,24(sp)
    800000ee:	e852                	sd	s4,16(sp)
    800000f0:	e456                	sd	s5,8(sp)
    800000f2:	e05a                	sd	s6,0(sp)
    800000f4:	0080                	addi	s0,sp,64
  p = (char *)PGROUNDUP((uint64)pa_start);
    800000f6:	6785                	lui	a5,0x1
    800000f8:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    800000fc:	94aa                	add	s1,s1,a0
    800000fe:	757d                	lui	a0,0xfffff
    80000100:	8ce9                	and	s1,s1,a0
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000102:	94be                	add	s1,s1,a5
    80000104:	0295ed63          	bltu	a1,s1,8000013e <freerange+0x5c>
    80000108:	89ae                	mv	s3,a1
    phypgrefer[PG_IDX((uint64)p)].count = 0;
    8000010a:	00009a97          	auipc	s5,0x9
    8000010e:	846a8a93          	addi	s5,s5,-1978 # 80008950 <phypgrefer>
    80000112:	fff80937          	lui	s2,0xfff80
    80000116:	197d                	addi	s2,s2,-1
    80000118:	0932                	slli	s2,s2,0xc
    kfree(p);
    8000011a:	7b7d                	lui	s6,0xfffff
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    8000011c:	6a05                	lui	s4,0x1
    phypgrefer[PG_IDX((uint64)p)].count = 0;
    8000011e:	012487b3          	add	a5,s1,s2
    80000122:	83b1                	srli	a5,a5,0xc
    80000124:	0796                	slli	a5,a5,0x5
    80000126:	97d6                	add	a5,a5,s5
    80000128:	00078c23          	sb	zero,24(a5)
    kfree(p);
    8000012c:	01648533          	add	a0,s1,s6
    80000130:	00000097          	auipc	ra,0x0
    80000134:	eec080e7          	jalr	-276(ra) # 8000001c <kfree>
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000138:	94d2                	add	s1,s1,s4
    8000013a:	fe99f2e3          	bgeu	s3,s1,8000011e <freerange+0x3c>
}
    8000013e:	70e2                	ld	ra,56(sp)
    80000140:	7442                	ld	s0,48(sp)
    80000142:	74a2                	ld	s1,40(sp)
    80000144:	7902                	ld	s2,32(sp)
    80000146:	69e2                	ld	s3,24(sp)
    80000148:	6a42                	ld	s4,16(sp)
    8000014a:	6aa2                	ld	s5,8(sp)
    8000014c:	6b02                	ld	s6,0(sp)
    8000014e:	6121                	addi	sp,sp,64
    80000150:	8082                	ret

0000000080000152 <kinit>:
{
    80000152:	7179                	addi	sp,sp,-48
    80000154:	f406                	sd	ra,40(sp)
    80000156:	f022                	sd	s0,32(sp)
    80000158:	ec26                	sd	s1,24(sp)
    8000015a:	e84a                	sd	s2,16(sp)
    8000015c:	e44e                	sd	s3,8(sp)
    8000015e:	1800                	addi	s0,sp,48
  initlock(&kmem.lock, "kmem");
    80000160:	00008597          	auipc	a1,0x8
    80000164:	eb858593          	addi	a1,a1,-328 # 80008018 <etext+0x18>
    80000168:	00008517          	auipc	a0,0x8
    8000016c:	7c850513          	addi	a0,a0,1992 # 80008930 <kmem>
    80000170:	00006097          	auipc	ra,0x6
    80000174:	1ba080e7          	jalr	442(ra) # 8000632a <initlock>
  for (int i = 0; i < (PHYSTOP - KERNBASE) / PGSIZE + 10; i++)
    80000178:	00008497          	auipc	s1,0x8
    8000017c:	7d848493          	addi	s1,s1,2008 # 80008950 <phypgrefer>
    80000180:	00109997          	auipc	s3,0x109
    80000184:	91098993          	addi	s3,s3,-1776 # 80108a90 <pid_lock>
    initlock(&(phypgrefer[i].lock), "phymem_ref");//初始化锁
    80000188:	00008917          	auipc	s2,0x8
    8000018c:	e9890913          	addi	s2,s2,-360 # 80008020 <etext+0x20>
    80000190:	85ca                	mv	a1,s2
    80000192:	8526                	mv	a0,s1
    80000194:	00006097          	auipc	ra,0x6
    80000198:	196080e7          	jalr	406(ra) # 8000632a <initlock>
  for (int i = 0; i < (PHYSTOP - KERNBASE) / PGSIZE + 10; i++)
    8000019c:	02048493          	addi	s1,s1,32
    800001a0:	ff3498e3          	bne	s1,s3,80000190 <kinit+0x3e>
  freerange(end, (void *)PHYSTOP);
    800001a4:	45c5                	li	a1,17
    800001a6:	05ee                	slli	a1,a1,0x1b
    800001a8:	00122517          	auipc	a0,0x122
    800001ac:	d3850513          	addi	a0,a0,-712 # 80121ee0 <end>
    800001b0:	00000097          	auipc	ra,0x0
    800001b4:	f32080e7          	jalr	-206(ra) # 800000e2 <freerange>
}
    800001b8:	70a2                	ld	ra,40(sp)
    800001ba:	7402                	ld	s0,32(sp)
    800001bc:	64e2                	ld	s1,24(sp)
    800001be:	6942                	ld	s2,16(sp)
    800001c0:	69a2                	ld	s3,8(sp)
    800001c2:	6145                	addi	sp,sp,48
    800001c4:	8082                	ret

00000000800001c6 <kalloc>:
//   return (void*)r;
// }

void *
kalloc(void)
{
    800001c6:	1101                	addi	sp,sp,-32
    800001c8:	ec06                	sd	ra,24(sp)
    800001ca:	e822                	sd	s0,16(sp)
    800001cc:	e426                	sd	s1,8(sp)
    800001ce:	e04a                	sd	s2,0(sp)
    800001d0:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    800001d2:	00008497          	auipc	s1,0x8
    800001d6:	75e48493          	addi	s1,s1,1886 # 80008930 <kmem>
    800001da:	8526                	mv	a0,s1
    800001dc:	00006097          	auipc	ra,0x6
    800001e0:	1de080e7          	jalr	478(ra) # 800063ba <acquire>
  r = kmem.freelist;
    800001e4:	0184b903          	ld	s2,24(s1)
  if (r)
    800001e8:	04090f63          	beqz	s2,80000246 <kalloc+0x80>
    kmem.freelist = r->next;
    800001ec:	00093783          	ld	a5,0(s2)
    800001f0:	8526                	mv	a0,s1
    800001f2:	ec9c                	sd	a5,24(s1)
  release(&kmem.lock);
    800001f4:	00006097          	auipc	ra,0x6
    800001f8:	27a080e7          	jalr	634(ra) # 8000646e <release>

  if (r)
  {
    memset((char *)r, 5, PGSIZE); // fill with junk
    800001fc:	6605                	lui	a2,0x1
    800001fe:	4595                	li	a1,5
    80000200:	854a                	mv	a0,s2
    80000202:	00000097          	auipc	ra,0x0
    80000206:	0c4080e7          	jalr	196(ra) # 800002c6 <memset>
    acquire(&phypgrefer[PG_IDX((uint64)r)].lock);//分配页面时将计数初始化为1
    8000020a:	800004b7          	lui	s1,0x80000
    8000020e:	94ca                	add	s1,s1,s2
    80000210:	80b1                	srli	s1,s1,0xc
    80000212:	0496                	slli	s1,s1,0x5
    80000214:	00008797          	auipc	a5,0x8
    80000218:	73c78793          	addi	a5,a5,1852 # 80008950 <phypgrefer>
    8000021c:	94be                	add	s1,s1,a5
    8000021e:	8526                	mv	a0,s1
    80000220:	00006097          	auipc	ra,0x6
    80000224:	19a080e7          	jalr	410(ra) # 800063ba <acquire>
    phypgrefer[PG_IDX((uint64)r)].count = 1;
    80000228:	4785                	li	a5,1
    8000022a:	00f48c23          	sb	a5,24(s1) # ffffffff80000018 <end+0xfffffffeffede138>
    release(&phypgrefer[PG_IDX((uint64)r)].lock);
    8000022e:	8526                	mv	a0,s1
    80000230:	00006097          	auipc	ra,0x6
    80000234:	23e080e7          	jalr	574(ra) # 8000646e <release>
  }
  return (void *)r;
}
    80000238:	854a                	mv	a0,s2
    8000023a:	60e2                	ld	ra,24(sp)
    8000023c:	6442                	ld	s0,16(sp)
    8000023e:	64a2                	ld	s1,8(sp)
    80000240:	6902                	ld	s2,0(sp)
    80000242:	6105                	addi	sp,sp,32
    80000244:	8082                	ret
  release(&kmem.lock);
    80000246:	00008517          	auipc	a0,0x8
    8000024a:	6ea50513          	addi	a0,a0,1770 # 80008930 <kmem>
    8000024e:	00006097          	auipc	ra,0x6
    80000252:	220080e7          	jalr	544(ra) # 8000646e <release>
  if (r)
    80000256:	b7cd                	j	80000238 <kalloc+0x72>

0000000080000258 <add_refer>:

// 当一个物理页面新增一个逻辑页面引用它时其引用计数值加1
int add_refer(uint64 pa)
{
  if ((uint64)pa % PGSIZE != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    80000258:	03451793          	slli	a5,a0,0x34
    8000025c:	efb9                	bnez	a5,800002ba <add_refer+0x62>
    8000025e:	00122797          	auipc	a5,0x122
    80000262:	c8278793          	addi	a5,a5,-894 # 80121ee0 <end>
    80000266:	04f56c63          	bltu	a0,a5,800002be <add_refer+0x66>
    8000026a:	47c5                	li	a5,17
    8000026c:	07ee                	slli	a5,a5,0x1b
    8000026e:	04f57a63          	bgeu	a0,a5,800002c2 <add_refer+0x6a>
{
    80000272:	1101                	addi	sp,sp,-32
    80000274:	ec06                	sd	ra,24(sp)
    80000276:	e822                	sd	s0,16(sp)
    80000278:	e426                	sd	s1,8(sp)
    8000027a:	1000                	addi	s0,sp,32
  {
    return -1;
  }
  acquire(&phypgrefer[PG_IDX((uint64)pa)].lock);
    8000027c:	800004b7          	lui	s1,0x80000
    80000280:	94aa                	add	s1,s1,a0
    80000282:	80b1                	srli	s1,s1,0xc
    80000284:	0496                	slli	s1,s1,0x5
    80000286:	00008517          	auipc	a0,0x8
    8000028a:	6ca50513          	addi	a0,a0,1738 # 80008950 <phypgrefer>
    8000028e:	94aa                	add	s1,s1,a0
    80000290:	8526                	mv	a0,s1
    80000292:	00006097          	auipc	ra,0x6
    80000296:	128080e7          	jalr	296(ra) # 800063ba <acquire>
  phypgrefer[PG_IDX((uint64)pa)].count += 1;
    8000029a:	0184c783          	lbu	a5,24(s1) # ffffffff80000018 <end+0xfffffffeffede138>
    8000029e:	2785                	addiw	a5,a5,1
    800002a0:	00f48c23          	sb	a5,24(s1)
  release(&phypgrefer[PG_IDX((uint64)pa)].lock);
    800002a4:	8526                	mv	a0,s1
    800002a6:	00006097          	auipc	ra,0x6
    800002aa:	1c8080e7          	jalr	456(ra) # 8000646e <release>
  return 0;
    800002ae:	4501                	li	a0,0
}
    800002b0:	60e2                	ld	ra,24(sp)
    800002b2:	6442                	ld	s0,16(sp)
    800002b4:	64a2                	ld	s1,8(sp)
    800002b6:	6105                	addi	sp,sp,32
    800002b8:	8082                	ret
    return -1;
    800002ba:	557d                	li	a0,-1
    800002bc:	8082                	ret
    800002be:	557d                	li	a0,-1
    800002c0:	8082                	ret
    800002c2:	557d                	li	a0,-1
}
    800002c4:	8082                	ret

00000000800002c6 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    800002c6:	1141                	addi	sp,sp,-16
    800002c8:	e422                	sd	s0,8(sp)
    800002ca:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    800002cc:	ca19                	beqz	a2,800002e2 <memset+0x1c>
    800002ce:	87aa                	mv	a5,a0
    800002d0:	1602                	slli	a2,a2,0x20
    800002d2:	9201                	srli	a2,a2,0x20
    800002d4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    800002d8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    800002dc:	0785                	addi	a5,a5,1
    800002de:	fee79de3          	bne	a5,a4,800002d8 <memset+0x12>
  }
  return dst;
}
    800002e2:	6422                	ld	s0,8(sp)
    800002e4:	0141                	addi	sp,sp,16
    800002e6:	8082                	ret

00000000800002e8 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    800002e8:	1141                	addi	sp,sp,-16
    800002ea:	e422                	sd	s0,8(sp)
    800002ec:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    800002ee:	ca05                	beqz	a2,8000031e <memcmp+0x36>
    800002f0:	fff6069b          	addiw	a3,a2,-1
    800002f4:	1682                	slli	a3,a3,0x20
    800002f6:	9281                	srli	a3,a3,0x20
    800002f8:	0685                	addi	a3,a3,1
    800002fa:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    800002fc:	00054783          	lbu	a5,0(a0)
    80000300:	0005c703          	lbu	a4,0(a1)
    80000304:	00e79863          	bne	a5,a4,80000314 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000308:	0505                	addi	a0,a0,1
    8000030a:	0585                	addi	a1,a1,1
  while(n-- > 0){
    8000030c:	fed518e3          	bne	a0,a3,800002fc <memcmp+0x14>
  }

  return 0;
    80000310:	4501                	li	a0,0
    80000312:	a019                	j	80000318 <memcmp+0x30>
      return *s1 - *s2;
    80000314:	40e7853b          	subw	a0,a5,a4
}
    80000318:	6422                	ld	s0,8(sp)
    8000031a:	0141                	addi	sp,sp,16
    8000031c:	8082                	ret
  return 0;
    8000031e:	4501                	li	a0,0
    80000320:	bfe5                	j	80000318 <memcmp+0x30>

0000000080000322 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000322:	1141                	addi	sp,sp,-16
    80000324:	e422                	sd	s0,8(sp)
    80000326:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000328:	c205                	beqz	a2,80000348 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    8000032a:	02a5e263          	bltu	a1,a0,8000034e <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    8000032e:	1602                	slli	a2,a2,0x20
    80000330:	9201                	srli	a2,a2,0x20
    80000332:	00c587b3          	add	a5,a1,a2
{
    80000336:	872a                	mv	a4,a0
      *d++ = *s++;
    80000338:	0585                	addi	a1,a1,1
    8000033a:	0705                	addi	a4,a4,1
    8000033c:	fff5c683          	lbu	a3,-1(a1)
    80000340:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000344:	fef59ae3          	bne	a1,a5,80000338 <memmove+0x16>

  return dst;
}
    80000348:	6422                	ld	s0,8(sp)
    8000034a:	0141                	addi	sp,sp,16
    8000034c:	8082                	ret
  if(s < d && s + n > d){
    8000034e:	02061693          	slli	a3,a2,0x20
    80000352:	9281                	srli	a3,a3,0x20
    80000354:	00d58733          	add	a4,a1,a3
    80000358:	fce57be3          	bgeu	a0,a4,8000032e <memmove+0xc>
    d += n;
    8000035c:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    8000035e:	fff6079b          	addiw	a5,a2,-1
    80000362:	1782                	slli	a5,a5,0x20
    80000364:	9381                	srli	a5,a5,0x20
    80000366:	fff7c793          	not	a5,a5
    8000036a:	97ba                	add	a5,a5,a4
      *--d = *--s;
    8000036c:	177d                	addi	a4,a4,-1
    8000036e:	16fd                	addi	a3,a3,-1
    80000370:	00074603          	lbu	a2,0(a4)
    80000374:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000378:	fee79ae3          	bne	a5,a4,8000036c <memmove+0x4a>
    8000037c:	b7f1                	j	80000348 <memmove+0x26>

000000008000037e <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    8000037e:	1141                	addi	sp,sp,-16
    80000380:	e406                	sd	ra,8(sp)
    80000382:	e022                	sd	s0,0(sp)
    80000384:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000386:	00000097          	auipc	ra,0x0
    8000038a:	f9c080e7          	jalr	-100(ra) # 80000322 <memmove>
}
    8000038e:	60a2                	ld	ra,8(sp)
    80000390:	6402                	ld	s0,0(sp)
    80000392:	0141                	addi	sp,sp,16
    80000394:	8082                	ret

0000000080000396 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000396:	1141                	addi	sp,sp,-16
    80000398:	e422                	sd	s0,8(sp)
    8000039a:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    8000039c:	ce11                	beqz	a2,800003b8 <strncmp+0x22>
    8000039e:	00054783          	lbu	a5,0(a0)
    800003a2:	cf89                	beqz	a5,800003bc <strncmp+0x26>
    800003a4:	0005c703          	lbu	a4,0(a1)
    800003a8:	00f71a63          	bne	a4,a5,800003bc <strncmp+0x26>
    n--, p++, q++;
    800003ac:	367d                	addiw	a2,a2,-1
    800003ae:	0505                	addi	a0,a0,1
    800003b0:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    800003b2:	f675                	bnez	a2,8000039e <strncmp+0x8>
  if(n == 0)
    return 0;
    800003b4:	4501                	li	a0,0
    800003b6:	a809                	j	800003c8 <strncmp+0x32>
    800003b8:	4501                	li	a0,0
    800003ba:	a039                	j	800003c8 <strncmp+0x32>
  if(n == 0)
    800003bc:	ca09                	beqz	a2,800003ce <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    800003be:	00054503          	lbu	a0,0(a0)
    800003c2:	0005c783          	lbu	a5,0(a1)
    800003c6:	9d1d                	subw	a0,a0,a5
}
    800003c8:	6422                	ld	s0,8(sp)
    800003ca:	0141                	addi	sp,sp,16
    800003cc:	8082                	ret
    return 0;
    800003ce:	4501                	li	a0,0
    800003d0:	bfe5                	j	800003c8 <strncmp+0x32>

00000000800003d2 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    800003d2:	1141                	addi	sp,sp,-16
    800003d4:	e422                	sd	s0,8(sp)
    800003d6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    800003d8:	872a                	mv	a4,a0
    800003da:	8832                	mv	a6,a2
    800003dc:	367d                	addiw	a2,a2,-1
    800003de:	01005963          	blez	a6,800003f0 <strncpy+0x1e>
    800003e2:	0705                	addi	a4,a4,1
    800003e4:	0005c783          	lbu	a5,0(a1)
    800003e8:	fef70fa3          	sb	a5,-1(a4)
    800003ec:	0585                	addi	a1,a1,1
    800003ee:	f7f5                	bnez	a5,800003da <strncpy+0x8>
    ;
  while(n-- > 0)
    800003f0:	86ba                	mv	a3,a4
    800003f2:	00c05c63          	blez	a2,8000040a <strncpy+0x38>
    *s++ = 0;
    800003f6:	0685                	addi	a3,a3,1
    800003f8:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    800003fc:	fff6c793          	not	a5,a3
    80000400:	9fb9                	addw	a5,a5,a4
    80000402:	010787bb          	addw	a5,a5,a6
    80000406:	fef048e3          	bgtz	a5,800003f6 <strncpy+0x24>
  return os;
}
    8000040a:	6422                	ld	s0,8(sp)
    8000040c:	0141                	addi	sp,sp,16
    8000040e:	8082                	ret

0000000080000410 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000410:	1141                	addi	sp,sp,-16
    80000412:	e422                	sd	s0,8(sp)
    80000414:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000416:	02c05363          	blez	a2,8000043c <safestrcpy+0x2c>
    8000041a:	fff6069b          	addiw	a3,a2,-1
    8000041e:	1682                	slli	a3,a3,0x20
    80000420:	9281                	srli	a3,a3,0x20
    80000422:	96ae                	add	a3,a3,a1
    80000424:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000426:	00d58963          	beq	a1,a3,80000438 <safestrcpy+0x28>
    8000042a:	0585                	addi	a1,a1,1
    8000042c:	0785                	addi	a5,a5,1
    8000042e:	fff5c703          	lbu	a4,-1(a1)
    80000432:	fee78fa3          	sb	a4,-1(a5)
    80000436:	fb65                	bnez	a4,80000426 <safestrcpy+0x16>
    ;
  *s = 0;
    80000438:	00078023          	sb	zero,0(a5)
  return os;
}
    8000043c:	6422                	ld	s0,8(sp)
    8000043e:	0141                	addi	sp,sp,16
    80000440:	8082                	ret

0000000080000442 <strlen>:

int
strlen(const char *s)
{
    80000442:	1141                	addi	sp,sp,-16
    80000444:	e422                	sd	s0,8(sp)
    80000446:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000448:	00054783          	lbu	a5,0(a0)
    8000044c:	cf91                	beqz	a5,80000468 <strlen+0x26>
    8000044e:	0505                	addi	a0,a0,1
    80000450:	87aa                	mv	a5,a0
    80000452:	4685                	li	a3,1
    80000454:	9e89                	subw	a3,a3,a0
    80000456:	00f6853b          	addw	a0,a3,a5
    8000045a:	0785                	addi	a5,a5,1
    8000045c:	fff7c703          	lbu	a4,-1(a5)
    80000460:	fb7d                	bnez	a4,80000456 <strlen+0x14>
    ;
  return n;
}
    80000462:	6422                	ld	s0,8(sp)
    80000464:	0141                	addi	sp,sp,16
    80000466:	8082                	ret
  for(n = 0; s[n]; n++)
    80000468:	4501                	li	a0,0
    8000046a:	bfe5                	j	80000462 <strlen+0x20>

000000008000046c <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    8000046c:	1141                	addi	sp,sp,-16
    8000046e:	e406                	sd	ra,8(sp)
    80000470:	e022                	sd	s0,0(sp)
    80000472:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000474:	00001097          	auipc	ra,0x1
    80000478:	c4a080e7          	jalr	-950(ra) # 800010be <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    8000047c:	00008717          	auipc	a4,0x8
    80000480:	48470713          	addi	a4,a4,1156 # 80008900 <started>
  if(cpuid() == 0){
    80000484:	c139                	beqz	a0,800004ca <main+0x5e>
    while(started == 0)
    80000486:	431c                	lw	a5,0(a4)
    80000488:	2781                	sext.w	a5,a5
    8000048a:	dff5                	beqz	a5,80000486 <main+0x1a>
      ;
    __sync_synchronize();
    8000048c:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000490:	00001097          	auipc	ra,0x1
    80000494:	c2e080e7          	jalr	-978(ra) # 800010be <cpuid>
    80000498:	85aa                	mv	a1,a0
    8000049a:	00008517          	auipc	a0,0x8
    8000049e:	bae50513          	addi	a0,a0,-1106 # 80008048 <etext+0x48>
    800004a2:	00006097          	auipc	ra,0x6
    800004a6:	a26080e7          	jalr	-1498(ra) # 80005ec8 <printf>
    kvminithart();    // turn on paging
    800004aa:	00000097          	auipc	ra,0x0
    800004ae:	0d8080e7          	jalr	216(ra) # 80000582 <kvminithart>
    trapinithart();   // install kernel trap vector
    800004b2:	00002097          	auipc	ra,0x2
    800004b6:	8d8080e7          	jalr	-1832(ra) # 80001d8a <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    800004ba:	00005097          	auipc	ra,0x5
    800004be:	ec6080e7          	jalr	-314(ra) # 80005380 <plicinithart>
  }

  scheduler();        
    800004c2:	00001097          	auipc	ra,0x1
    800004c6:	122080e7          	jalr	290(ra) # 800015e4 <scheduler>
    consoleinit();
    800004ca:	00006097          	auipc	ra,0x6
    800004ce:	8c6080e7          	jalr	-1850(ra) # 80005d90 <consoleinit>
    printfinit();
    800004d2:	00006097          	auipc	ra,0x6
    800004d6:	bd6080e7          	jalr	-1066(ra) # 800060a8 <printfinit>
    printf("\n");
    800004da:	00008517          	auipc	a0,0x8
    800004de:	b7e50513          	addi	a0,a0,-1154 # 80008058 <etext+0x58>
    800004e2:	00006097          	auipc	ra,0x6
    800004e6:	9e6080e7          	jalr	-1562(ra) # 80005ec8 <printf>
    printf("xv6 kernel is booting\n");
    800004ea:	00008517          	auipc	a0,0x8
    800004ee:	b4650513          	addi	a0,a0,-1210 # 80008030 <etext+0x30>
    800004f2:	00006097          	auipc	ra,0x6
    800004f6:	9d6080e7          	jalr	-1578(ra) # 80005ec8 <printf>
    printf("\n");
    800004fa:	00008517          	auipc	a0,0x8
    800004fe:	b5e50513          	addi	a0,a0,-1186 # 80008058 <etext+0x58>
    80000502:	00006097          	auipc	ra,0x6
    80000506:	9c6080e7          	jalr	-1594(ra) # 80005ec8 <printf>
    kinit();         // physical page allocator
    8000050a:	00000097          	auipc	ra,0x0
    8000050e:	c48080e7          	jalr	-952(ra) # 80000152 <kinit>
    kvminit();       // create kernel page table
    80000512:	00000097          	auipc	ra,0x0
    80000516:	34a080e7          	jalr	842(ra) # 8000085c <kvminit>
    kvminithart();   // turn on paging
    8000051a:	00000097          	auipc	ra,0x0
    8000051e:	068080e7          	jalr	104(ra) # 80000582 <kvminithart>
    procinit();      // process table
    80000522:	00001097          	auipc	ra,0x1
    80000526:	ae8080e7          	jalr	-1304(ra) # 8000100a <procinit>
    trapinit();      // trap vectors
    8000052a:	00002097          	auipc	ra,0x2
    8000052e:	838080e7          	jalr	-1992(ra) # 80001d62 <trapinit>
    trapinithart();  // install kernel trap vector
    80000532:	00002097          	auipc	ra,0x2
    80000536:	858080e7          	jalr	-1960(ra) # 80001d8a <trapinithart>
    plicinit();      // set up interrupt controller
    8000053a:	00005097          	auipc	ra,0x5
    8000053e:	e30080e7          	jalr	-464(ra) # 8000536a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000542:	00005097          	auipc	ra,0x5
    80000546:	e3e080e7          	jalr	-450(ra) # 80005380 <plicinithart>
    binit();         // buffer cache
    8000054a:	00002097          	auipc	ra,0x2
    8000054e:	fde080e7          	jalr	-34(ra) # 80002528 <binit>
    iinit();         // inode table
    80000552:	00002097          	auipc	ra,0x2
    80000556:	682080e7          	jalr	1666(ra) # 80002bd4 <iinit>
    fileinit();      // file table
    8000055a:	00003097          	auipc	ra,0x3
    8000055e:	620080e7          	jalr	1568(ra) # 80003b7a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000562:	00005097          	auipc	ra,0x5
    80000566:	f26080e7          	jalr	-218(ra) # 80005488 <virtio_disk_init>
    userinit();      // first user process
    8000056a:	00001097          	auipc	ra,0x1
    8000056e:	e5c080e7          	jalr	-420(ra) # 800013c6 <userinit>
    __sync_synchronize();
    80000572:	0ff0000f          	fence
    started = 1;
    80000576:	4785                	li	a5,1
    80000578:	00008717          	auipc	a4,0x8
    8000057c:	38f72423          	sw	a5,904(a4) # 80008900 <started>
    80000580:	b789                	j	800004c2 <main+0x56>

0000000080000582 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000582:	1141                	addi	sp,sp,-16
    80000584:	e422                	sd	s0,8(sp)
    80000586:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000588:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    8000058c:	00008797          	auipc	a5,0x8
    80000590:	37c7b783          	ld	a5,892(a5) # 80008908 <kernel_pagetable>
    80000594:	83b1                	srli	a5,a5,0xc
    80000596:	577d                	li	a4,-1
    80000598:	177e                	slli	a4,a4,0x3f
    8000059a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    8000059c:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    800005a0:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    800005a4:	6422                	ld	s0,8(sp)
    800005a6:	0141                	addi	sp,sp,16
    800005a8:	8082                	ret

00000000800005aa <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800005aa:	7139                	addi	sp,sp,-64
    800005ac:	fc06                	sd	ra,56(sp)
    800005ae:	f822                	sd	s0,48(sp)
    800005b0:	f426                	sd	s1,40(sp)
    800005b2:	f04a                	sd	s2,32(sp)
    800005b4:	ec4e                	sd	s3,24(sp)
    800005b6:	e852                	sd	s4,16(sp)
    800005b8:	e456                	sd	s5,8(sp)
    800005ba:	e05a                	sd	s6,0(sp)
    800005bc:	0080                	addi	s0,sp,64
    800005be:	84aa                	mv	s1,a0
    800005c0:	89ae                	mv	s3,a1
    800005c2:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    800005c4:	57fd                	li	a5,-1
    800005c6:	83e9                	srli	a5,a5,0x1a
    800005c8:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800005ca:	4b31                	li	s6,12
  if(va >= MAXVA)
    800005cc:	04b7f263          	bgeu	a5,a1,80000610 <walk+0x66>
    panic("walk");
    800005d0:	00008517          	auipc	a0,0x8
    800005d4:	a9050513          	addi	a0,a0,-1392 # 80008060 <etext+0x60>
    800005d8:	00006097          	auipc	ra,0x6
    800005dc:	8a6080e7          	jalr	-1882(ra) # 80005e7e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800005e0:	060a8663          	beqz	s5,8000064c <walk+0xa2>
    800005e4:	00000097          	auipc	ra,0x0
    800005e8:	be2080e7          	jalr	-1054(ra) # 800001c6 <kalloc>
    800005ec:	84aa                	mv	s1,a0
    800005ee:	c529                	beqz	a0,80000638 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800005f0:	6605                	lui	a2,0x1
    800005f2:	4581                	li	a1,0
    800005f4:	00000097          	auipc	ra,0x0
    800005f8:	cd2080e7          	jalr	-814(ra) # 800002c6 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800005fc:	00c4d793          	srli	a5,s1,0xc
    80000600:	07aa                	slli	a5,a5,0xa
    80000602:	0017e793          	ori	a5,a5,1
    80000606:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000060a:	3a5d                	addiw	s4,s4,-9
    8000060c:	036a0063          	beq	s4,s6,8000062c <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80000610:	0149d933          	srl	s2,s3,s4
    80000614:	1ff97913          	andi	s2,s2,511
    80000618:	090e                	slli	s2,s2,0x3
    8000061a:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000061c:	00093483          	ld	s1,0(s2)
    80000620:	0014f793          	andi	a5,s1,1
    80000624:	dfd5                	beqz	a5,800005e0 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000626:	80a9                	srli	s1,s1,0xa
    80000628:	04b2                	slli	s1,s1,0xc
    8000062a:	b7c5                	j	8000060a <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000062c:	00c9d513          	srli	a0,s3,0xc
    80000630:	1ff57513          	andi	a0,a0,511
    80000634:	050e                	slli	a0,a0,0x3
    80000636:	9526                	add	a0,a0,s1
}
    80000638:	70e2                	ld	ra,56(sp)
    8000063a:	7442                	ld	s0,48(sp)
    8000063c:	74a2                	ld	s1,40(sp)
    8000063e:	7902                	ld	s2,32(sp)
    80000640:	69e2                	ld	s3,24(sp)
    80000642:	6a42                	ld	s4,16(sp)
    80000644:	6aa2                	ld	s5,8(sp)
    80000646:	6b02                	ld	s6,0(sp)
    80000648:	6121                	addi	sp,sp,64
    8000064a:	8082                	ret
        return 0;
    8000064c:	4501                	li	a0,0
    8000064e:	b7ed                	j	80000638 <walk+0x8e>

0000000080000650 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000650:	57fd                	li	a5,-1
    80000652:	83e9                	srli	a5,a5,0x1a
    80000654:	00b7f463          	bgeu	a5,a1,8000065c <walkaddr+0xc>
    return 0;
    80000658:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000065a:	8082                	ret
{
    8000065c:	1141                	addi	sp,sp,-16
    8000065e:	e406                	sd	ra,8(sp)
    80000660:	e022                	sd	s0,0(sp)
    80000662:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000664:	4601                	li	a2,0
    80000666:	00000097          	auipc	ra,0x0
    8000066a:	f44080e7          	jalr	-188(ra) # 800005aa <walk>
  if(pte == 0)
    8000066e:	c105                	beqz	a0,8000068e <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80000670:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000672:	0117f693          	andi	a3,a5,17
    80000676:	4745                	li	a4,17
    return 0;
    80000678:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000067a:	00e68663          	beq	a3,a4,80000686 <walkaddr+0x36>
}
    8000067e:	60a2                	ld	ra,8(sp)
    80000680:	6402                	ld	s0,0(sp)
    80000682:	0141                	addi	sp,sp,16
    80000684:	8082                	ret
  pa = PTE2PA(*pte);
    80000686:	00a7d513          	srli	a0,a5,0xa
    8000068a:	0532                	slli	a0,a0,0xc
  return pa;
    8000068c:	bfcd                	j	8000067e <walkaddr+0x2e>
    return 0;
    8000068e:	4501                	li	a0,0
    80000690:	b7fd                	j	8000067e <walkaddr+0x2e>

0000000080000692 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000692:	715d                	addi	sp,sp,-80
    80000694:	e486                	sd	ra,72(sp)
    80000696:	e0a2                	sd	s0,64(sp)
    80000698:	fc26                	sd	s1,56(sp)
    8000069a:	f84a                	sd	s2,48(sp)
    8000069c:	f44e                	sd	s3,40(sp)
    8000069e:	f052                	sd	s4,32(sp)
    800006a0:	ec56                	sd	s5,24(sp)
    800006a2:	e85a                	sd	s6,16(sp)
    800006a4:	e45e                	sd	s7,8(sp)
    800006a6:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800006a8:	03459793          	slli	a5,a1,0x34
    800006ac:	e7b9                	bnez	a5,800006fa <mappages+0x68>
    800006ae:	8aaa                	mv	s5,a0
    800006b0:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    800006b2:	03461793          	slli	a5,a2,0x34
    800006b6:	ebb1                	bnez	a5,8000070a <mappages+0x78>
    panic("mappages: size not aligned");

  if(size == 0)
    800006b8:	c22d                	beqz	a2,8000071a <mappages+0x88>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    800006ba:	79fd                	lui	s3,0xfffff
    800006bc:	964e                	add	a2,a2,s3
    800006be:	00b609b3          	add	s3,a2,a1
  a = va;
    800006c2:	892e                	mv	s2,a1
    800006c4:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800006c8:	6b85                	lui	s7,0x1
    800006ca:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800006ce:	4605                	li	a2,1
    800006d0:	85ca                	mv	a1,s2
    800006d2:	8556                	mv	a0,s5
    800006d4:	00000097          	auipc	ra,0x0
    800006d8:	ed6080e7          	jalr	-298(ra) # 800005aa <walk>
    800006dc:	cd39                	beqz	a0,8000073a <mappages+0xa8>
    if(*pte & PTE_V)
    800006de:	611c                	ld	a5,0(a0)
    800006e0:	8b85                	andi	a5,a5,1
    800006e2:	e7a1                	bnez	a5,8000072a <mappages+0x98>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800006e4:	80b1                	srli	s1,s1,0xc
    800006e6:	04aa                	slli	s1,s1,0xa
    800006e8:	0164e4b3          	or	s1,s1,s6
    800006ec:	0014e493          	ori	s1,s1,1
    800006f0:	e104                	sd	s1,0(a0)
    if(a == last)
    800006f2:	07390063          	beq	s2,s3,80000752 <mappages+0xc0>
    a += PGSIZE;
    800006f6:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800006f8:	bfc9                	j	800006ca <mappages+0x38>
    panic("mappages: va not aligned");
    800006fa:	00008517          	auipc	a0,0x8
    800006fe:	96e50513          	addi	a0,a0,-1682 # 80008068 <etext+0x68>
    80000702:	00005097          	auipc	ra,0x5
    80000706:	77c080e7          	jalr	1916(ra) # 80005e7e <panic>
    panic("mappages: size not aligned");
    8000070a:	00008517          	auipc	a0,0x8
    8000070e:	97e50513          	addi	a0,a0,-1666 # 80008088 <etext+0x88>
    80000712:	00005097          	auipc	ra,0x5
    80000716:	76c080e7          	jalr	1900(ra) # 80005e7e <panic>
    panic("mappages: size");
    8000071a:	00008517          	auipc	a0,0x8
    8000071e:	98e50513          	addi	a0,a0,-1650 # 800080a8 <etext+0xa8>
    80000722:	00005097          	auipc	ra,0x5
    80000726:	75c080e7          	jalr	1884(ra) # 80005e7e <panic>
      panic("mappages: remap");
    8000072a:	00008517          	auipc	a0,0x8
    8000072e:	98e50513          	addi	a0,a0,-1650 # 800080b8 <etext+0xb8>
    80000732:	00005097          	auipc	ra,0x5
    80000736:	74c080e7          	jalr	1868(ra) # 80005e7e <panic>
      return -1;
    8000073a:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000073c:	60a6                	ld	ra,72(sp)
    8000073e:	6406                	ld	s0,64(sp)
    80000740:	74e2                	ld	s1,56(sp)
    80000742:	7942                	ld	s2,48(sp)
    80000744:	79a2                	ld	s3,40(sp)
    80000746:	7a02                	ld	s4,32(sp)
    80000748:	6ae2                	ld	s5,24(sp)
    8000074a:	6b42                	ld	s6,16(sp)
    8000074c:	6ba2                	ld	s7,8(sp)
    8000074e:	6161                	addi	sp,sp,80
    80000750:	8082                	ret
  return 0;
    80000752:	4501                	li	a0,0
    80000754:	b7e5                	j	8000073c <mappages+0xaa>

0000000080000756 <kvmmap>:
{
    80000756:	1141                	addi	sp,sp,-16
    80000758:	e406                	sd	ra,8(sp)
    8000075a:	e022                	sd	s0,0(sp)
    8000075c:	0800                	addi	s0,sp,16
    8000075e:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80000760:	86b2                	mv	a3,a2
    80000762:	863e                	mv	a2,a5
    80000764:	00000097          	auipc	ra,0x0
    80000768:	f2e080e7          	jalr	-210(ra) # 80000692 <mappages>
    8000076c:	e509                	bnez	a0,80000776 <kvmmap+0x20>
}
    8000076e:	60a2                	ld	ra,8(sp)
    80000770:	6402                	ld	s0,0(sp)
    80000772:	0141                	addi	sp,sp,16
    80000774:	8082                	ret
    panic("kvmmap");
    80000776:	00008517          	auipc	a0,0x8
    8000077a:	95250513          	addi	a0,a0,-1710 # 800080c8 <etext+0xc8>
    8000077e:	00005097          	auipc	ra,0x5
    80000782:	700080e7          	jalr	1792(ra) # 80005e7e <panic>

0000000080000786 <kvmmake>:
{
    80000786:	1101                	addi	sp,sp,-32
    80000788:	ec06                	sd	ra,24(sp)
    8000078a:	e822                	sd	s0,16(sp)
    8000078c:	e426                	sd	s1,8(sp)
    8000078e:	e04a                	sd	s2,0(sp)
    80000790:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80000792:	00000097          	auipc	ra,0x0
    80000796:	a34080e7          	jalr	-1484(ra) # 800001c6 <kalloc>
    8000079a:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000079c:	6605                	lui	a2,0x1
    8000079e:	4581                	li	a1,0
    800007a0:	00000097          	auipc	ra,0x0
    800007a4:	b26080e7          	jalr	-1242(ra) # 800002c6 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800007a8:	4719                	li	a4,6
    800007aa:	6685                	lui	a3,0x1
    800007ac:	10000637          	lui	a2,0x10000
    800007b0:	100005b7          	lui	a1,0x10000
    800007b4:	8526                	mv	a0,s1
    800007b6:	00000097          	auipc	ra,0x0
    800007ba:	fa0080e7          	jalr	-96(ra) # 80000756 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800007be:	4719                	li	a4,6
    800007c0:	6685                	lui	a3,0x1
    800007c2:	10001637          	lui	a2,0x10001
    800007c6:	100015b7          	lui	a1,0x10001
    800007ca:	8526                	mv	a0,s1
    800007cc:	00000097          	auipc	ra,0x0
    800007d0:	f8a080e7          	jalr	-118(ra) # 80000756 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800007d4:	4719                	li	a4,6
    800007d6:	004006b7          	lui	a3,0x400
    800007da:	0c000637          	lui	a2,0xc000
    800007de:	0c0005b7          	lui	a1,0xc000
    800007e2:	8526                	mv	a0,s1
    800007e4:	00000097          	auipc	ra,0x0
    800007e8:	f72080e7          	jalr	-142(ra) # 80000756 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800007ec:	00008917          	auipc	s2,0x8
    800007f0:	81490913          	addi	s2,s2,-2028 # 80008000 <etext>
    800007f4:	4729                	li	a4,10
    800007f6:	80008697          	auipc	a3,0x80008
    800007fa:	80a68693          	addi	a3,a3,-2038 # 8000 <_entry-0x7fff8000>
    800007fe:	4605                	li	a2,1
    80000800:	067e                	slli	a2,a2,0x1f
    80000802:	85b2                	mv	a1,a2
    80000804:	8526                	mv	a0,s1
    80000806:	00000097          	auipc	ra,0x0
    8000080a:	f50080e7          	jalr	-176(ra) # 80000756 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000080e:	4719                	li	a4,6
    80000810:	46c5                	li	a3,17
    80000812:	06ee                	slli	a3,a3,0x1b
    80000814:	412686b3          	sub	a3,a3,s2
    80000818:	864a                	mv	a2,s2
    8000081a:	85ca                	mv	a1,s2
    8000081c:	8526                	mv	a0,s1
    8000081e:	00000097          	auipc	ra,0x0
    80000822:	f38080e7          	jalr	-200(ra) # 80000756 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80000826:	4729                	li	a4,10
    80000828:	6685                	lui	a3,0x1
    8000082a:	00006617          	auipc	a2,0x6
    8000082e:	7d660613          	addi	a2,a2,2006 # 80007000 <_trampoline>
    80000832:	040005b7          	lui	a1,0x4000
    80000836:	15fd                	addi	a1,a1,-1
    80000838:	05b2                	slli	a1,a1,0xc
    8000083a:	8526                	mv	a0,s1
    8000083c:	00000097          	auipc	ra,0x0
    80000840:	f1a080e7          	jalr	-230(ra) # 80000756 <kvmmap>
  proc_mapstacks(kpgtbl);
    80000844:	8526                	mv	a0,s1
    80000846:	00000097          	auipc	ra,0x0
    8000084a:	72e080e7          	jalr	1838(ra) # 80000f74 <proc_mapstacks>
}
    8000084e:	8526                	mv	a0,s1
    80000850:	60e2                	ld	ra,24(sp)
    80000852:	6442                	ld	s0,16(sp)
    80000854:	64a2                	ld	s1,8(sp)
    80000856:	6902                	ld	s2,0(sp)
    80000858:	6105                	addi	sp,sp,32
    8000085a:	8082                	ret

000000008000085c <kvminit>:
{
    8000085c:	1141                	addi	sp,sp,-16
    8000085e:	e406                	sd	ra,8(sp)
    80000860:	e022                	sd	s0,0(sp)
    80000862:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80000864:	00000097          	auipc	ra,0x0
    80000868:	f22080e7          	jalr	-222(ra) # 80000786 <kvmmake>
    8000086c:	00008797          	auipc	a5,0x8
    80000870:	08a7be23          	sd	a0,156(a5) # 80008908 <kernel_pagetable>
}
    80000874:	60a2                	ld	ra,8(sp)
    80000876:	6402                	ld	s0,0(sp)
    80000878:	0141                	addi	sp,sp,16
    8000087a:	8082                	ret

000000008000087c <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000087c:	715d                	addi	sp,sp,-80
    8000087e:	e486                	sd	ra,72(sp)
    80000880:	e0a2                	sd	s0,64(sp)
    80000882:	fc26                	sd	s1,56(sp)
    80000884:	f84a                	sd	s2,48(sp)
    80000886:	f44e                	sd	s3,40(sp)
    80000888:	f052                	sd	s4,32(sp)
    8000088a:	ec56                	sd	s5,24(sp)
    8000088c:	e85a                	sd	s6,16(sp)
    8000088e:	e45e                	sd	s7,8(sp)
    80000890:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80000892:	03459793          	slli	a5,a1,0x34
    80000896:	e795                	bnez	a5,800008c2 <uvmunmap+0x46>
    80000898:	8a2a                	mv	s4,a0
    8000089a:	892e                	mv	s2,a1
    8000089c:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000089e:	0632                	slli	a2,a2,0xc
    800008a0:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800008a4:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800008a6:	6b05                	lui	s6,0x1
    800008a8:	0735e263          	bltu	a1,s3,8000090c <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800008ac:	60a6                	ld	ra,72(sp)
    800008ae:	6406                	ld	s0,64(sp)
    800008b0:	74e2                	ld	s1,56(sp)
    800008b2:	7942                	ld	s2,48(sp)
    800008b4:	79a2                	ld	s3,40(sp)
    800008b6:	7a02                	ld	s4,32(sp)
    800008b8:	6ae2                	ld	s5,24(sp)
    800008ba:	6b42                	ld	s6,16(sp)
    800008bc:	6ba2                	ld	s7,8(sp)
    800008be:	6161                	addi	sp,sp,80
    800008c0:	8082                	ret
    panic("uvmunmap: not aligned");
    800008c2:	00008517          	auipc	a0,0x8
    800008c6:	80e50513          	addi	a0,a0,-2034 # 800080d0 <etext+0xd0>
    800008ca:	00005097          	auipc	ra,0x5
    800008ce:	5b4080e7          	jalr	1460(ra) # 80005e7e <panic>
      panic("uvmunmap: walk");
    800008d2:	00008517          	auipc	a0,0x8
    800008d6:	81650513          	addi	a0,a0,-2026 # 800080e8 <etext+0xe8>
    800008da:	00005097          	auipc	ra,0x5
    800008de:	5a4080e7          	jalr	1444(ra) # 80005e7e <panic>
      panic("uvmunmap: not mapped");
    800008e2:	00008517          	auipc	a0,0x8
    800008e6:	81650513          	addi	a0,a0,-2026 # 800080f8 <etext+0xf8>
    800008ea:	00005097          	auipc	ra,0x5
    800008ee:	594080e7          	jalr	1428(ra) # 80005e7e <panic>
      panic("uvmunmap: not a leaf");
    800008f2:	00008517          	auipc	a0,0x8
    800008f6:	81e50513          	addi	a0,a0,-2018 # 80008110 <etext+0x110>
    800008fa:	00005097          	auipc	ra,0x5
    800008fe:	584080e7          	jalr	1412(ra) # 80005e7e <panic>
    *pte = 0;
    80000902:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80000906:	995a                	add	s2,s2,s6
    80000908:	fb3972e3          	bgeu	s2,s3,800008ac <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    8000090c:	4601                	li	a2,0
    8000090e:	85ca                	mv	a1,s2
    80000910:	8552                	mv	a0,s4
    80000912:	00000097          	auipc	ra,0x0
    80000916:	c98080e7          	jalr	-872(ra) # 800005aa <walk>
    8000091a:	84aa                	mv	s1,a0
    8000091c:	d95d                	beqz	a0,800008d2 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    8000091e:	6108                	ld	a0,0(a0)
    80000920:	00157793          	andi	a5,a0,1
    80000924:	dfdd                	beqz	a5,800008e2 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80000926:	3ff57793          	andi	a5,a0,1023
    8000092a:	fd7784e3          	beq	a5,s7,800008f2 <uvmunmap+0x76>
    if(do_free){
    8000092e:	fc0a8ae3          	beqz	s5,80000902 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80000932:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80000934:	0532                	slli	a0,a0,0xc
    80000936:	fffff097          	auipc	ra,0xfffff
    8000093a:	6e6080e7          	jalr	1766(ra) # 8000001c <kfree>
    8000093e:	b7d1                	j	80000902 <uvmunmap+0x86>

0000000080000940 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80000940:	1101                	addi	sp,sp,-32
    80000942:	ec06                	sd	ra,24(sp)
    80000944:	e822                	sd	s0,16(sp)
    80000946:	e426                	sd	s1,8(sp)
    80000948:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000094a:	00000097          	auipc	ra,0x0
    8000094e:	87c080e7          	jalr	-1924(ra) # 800001c6 <kalloc>
    80000952:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80000954:	c519                	beqz	a0,80000962 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80000956:	6605                	lui	a2,0x1
    80000958:	4581                	li	a1,0
    8000095a:	00000097          	auipc	ra,0x0
    8000095e:	96c080e7          	jalr	-1684(ra) # 800002c6 <memset>
  return pagetable;
}
    80000962:	8526                	mv	a0,s1
    80000964:	60e2                	ld	ra,24(sp)
    80000966:	6442                	ld	s0,16(sp)
    80000968:	64a2                	ld	s1,8(sp)
    8000096a:	6105                	addi	sp,sp,32
    8000096c:	8082                	ret

000000008000096e <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    8000096e:	7179                	addi	sp,sp,-48
    80000970:	f406                	sd	ra,40(sp)
    80000972:	f022                	sd	s0,32(sp)
    80000974:	ec26                	sd	s1,24(sp)
    80000976:	e84a                	sd	s2,16(sp)
    80000978:	e44e                	sd	s3,8(sp)
    8000097a:	e052                	sd	s4,0(sp)
    8000097c:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000097e:	6785                	lui	a5,0x1
    80000980:	04f67863          	bgeu	a2,a5,800009d0 <uvmfirst+0x62>
    80000984:	8a2a                	mv	s4,a0
    80000986:	89ae                	mv	s3,a1
    80000988:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000098a:	00000097          	auipc	ra,0x0
    8000098e:	83c080e7          	jalr	-1988(ra) # 800001c6 <kalloc>
    80000992:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80000994:	6605                	lui	a2,0x1
    80000996:	4581                	li	a1,0
    80000998:	00000097          	auipc	ra,0x0
    8000099c:	92e080e7          	jalr	-1746(ra) # 800002c6 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800009a0:	4779                	li	a4,30
    800009a2:	86ca                	mv	a3,s2
    800009a4:	6605                	lui	a2,0x1
    800009a6:	4581                	li	a1,0
    800009a8:	8552                	mv	a0,s4
    800009aa:	00000097          	auipc	ra,0x0
    800009ae:	ce8080e7          	jalr	-792(ra) # 80000692 <mappages>
  memmove(mem, src, sz);
    800009b2:	8626                	mv	a2,s1
    800009b4:	85ce                	mv	a1,s3
    800009b6:	854a                	mv	a0,s2
    800009b8:	00000097          	auipc	ra,0x0
    800009bc:	96a080e7          	jalr	-1686(ra) # 80000322 <memmove>
}
    800009c0:	70a2                	ld	ra,40(sp)
    800009c2:	7402                	ld	s0,32(sp)
    800009c4:	64e2                	ld	s1,24(sp)
    800009c6:	6942                	ld	s2,16(sp)
    800009c8:	69a2                	ld	s3,8(sp)
    800009ca:	6a02                	ld	s4,0(sp)
    800009cc:	6145                	addi	sp,sp,48
    800009ce:	8082                	ret
    panic("uvmfirst: more than a page");
    800009d0:	00007517          	auipc	a0,0x7
    800009d4:	75850513          	addi	a0,a0,1880 # 80008128 <etext+0x128>
    800009d8:	00005097          	auipc	ra,0x5
    800009dc:	4a6080e7          	jalr	1190(ra) # 80005e7e <panic>

00000000800009e0 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800009e0:	1101                	addi	sp,sp,-32
    800009e2:	ec06                	sd	ra,24(sp)
    800009e4:	e822                	sd	s0,16(sp)
    800009e6:	e426                	sd	s1,8(sp)
    800009e8:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800009ea:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800009ec:	00b67d63          	bgeu	a2,a1,80000a06 <uvmdealloc+0x26>
    800009f0:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800009f2:	6785                	lui	a5,0x1
    800009f4:	17fd                	addi	a5,a5,-1
    800009f6:	00f60733          	add	a4,a2,a5
    800009fa:	767d                	lui	a2,0xfffff
    800009fc:	8f71                	and	a4,a4,a2
    800009fe:	97ae                	add	a5,a5,a1
    80000a00:	8ff1                	and	a5,a5,a2
    80000a02:	00f76863          	bltu	a4,a5,80000a12 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80000a06:	8526                	mv	a0,s1
    80000a08:	60e2                	ld	ra,24(sp)
    80000a0a:	6442                	ld	s0,16(sp)
    80000a0c:	64a2                	ld	s1,8(sp)
    80000a0e:	6105                	addi	sp,sp,32
    80000a10:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80000a12:	8f99                	sub	a5,a5,a4
    80000a14:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80000a16:	4685                	li	a3,1
    80000a18:	0007861b          	sext.w	a2,a5
    80000a1c:	85ba                	mv	a1,a4
    80000a1e:	00000097          	auipc	ra,0x0
    80000a22:	e5e080e7          	jalr	-418(ra) # 8000087c <uvmunmap>
    80000a26:	b7c5                	j	80000a06 <uvmdealloc+0x26>

0000000080000a28 <uvmalloc>:
  if(newsz < oldsz)
    80000a28:	0ab66563          	bltu	a2,a1,80000ad2 <uvmalloc+0xaa>
{
    80000a2c:	7139                	addi	sp,sp,-64
    80000a2e:	fc06                	sd	ra,56(sp)
    80000a30:	f822                	sd	s0,48(sp)
    80000a32:	f426                	sd	s1,40(sp)
    80000a34:	f04a                	sd	s2,32(sp)
    80000a36:	ec4e                	sd	s3,24(sp)
    80000a38:	e852                	sd	s4,16(sp)
    80000a3a:	e456                	sd	s5,8(sp)
    80000a3c:	e05a                	sd	s6,0(sp)
    80000a3e:	0080                	addi	s0,sp,64
    80000a40:	8aaa                	mv	s5,a0
    80000a42:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80000a44:	6985                	lui	s3,0x1
    80000a46:	19fd                	addi	s3,s3,-1
    80000a48:	95ce                	add	a1,a1,s3
    80000a4a:	79fd                	lui	s3,0xfffff
    80000a4c:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80000a50:	08c9f363          	bgeu	s3,a2,80000ad6 <uvmalloc+0xae>
    80000a54:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80000a56:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80000a5a:	fffff097          	auipc	ra,0xfffff
    80000a5e:	76c080e7          	jalr	1900(ra) # 800001c6 <kalloc>
    80000a62:	84aa                	mv	s1,a0
    if(mem == 0){
    80000a64:	c51d                	beqz	a0,80000a92 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    80000a66:	6605                	lui	a2,0x1
    80000a68:	4581                	li	a1,0
    80000a6a:	00000097          	auipc	ra,0x0
    80000a6e:	85c080e7          	jalr	-1956(ra) # 800002c6 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80000a72:	875a                	mv	a4,s6
    80000a74:	86a6                	mv	a3,s1
    80000a76:	6605                	lui	a2,0x1
    80000a78:	85ca                	mv	a1,s2
    80000a7a:	8556                	mv	a0,s5
    80000a7c:	00000097          	auipc	ra,0x0
    80000a80:	c16080e7          	jalr	-1002(ra) # 80000692 <mappages>
    80000a84:	e90d                	bnez	a0,80000ab6 <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80000a86:	6785                	lui	a5,0x1
    80000a88:	993e                	add	s2,s2,a5
    80000a8a:	fd4968e3          	bltu	s2,s4,80000a5a <uvmalloc+0x32>
  return newsz;
    80000a8e:	8552                	mv	a0,s4
    80000a90:	a809                	j	80000aa2 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    80000a92:	864e                	mv	a2,s3
    80000a94:	85ca                	mv	a1,s2
    80000a96:	8556                	mv	a0,s5
    80000a98:	00000097          	auipc	ra,0x0
    80000a9c:	f48080e7          	jalr	-184(ra) # 800009e0 <uvmdealloc>
      return 0;
    80000aa0:	4501                	li	a0,0
}
    80000aa2:	70e2                	ld	ra,56(sp)
    80000aa4:	7442                	ld	s0,48(sp)
    80000aa6:	74a2                	ld	s1,40(sp)
    80000aa8:	7902                	ld	s2,32(sp)
    80000aaa:	69e2                	ld	s3,24(sp)
    80000aac:	6a42                	ld	s4,16(sp)
    80000aae:	6aa2                	ld	s5,8(sp)
    80000ab0:	6b02                	ld	s6,0(sp)
    80000ab2:	6121                	addi	sp,sp,64
    80000ab4:	8082                	ret
      kfree(mem);
    80000ab6:	8526                	mv	a0,s1
    80000ab8:	fffff097          	auipc	ra,0xfffff
    80000abc:	564080e7          	jalr	1380(ra) # 8000001c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80000ac0:	864e                	mv	a2,s3
    80000ac2:	85ca                	mv	a1,s2
    80000ac4:	8556                	mv	a0,s5
    80000ac6:	00000097          	auipc	ra,0x0
    80000aca:	f1a080e7          	jalr	-230(ra) # 800009e0 <uvmdealloc>
      return 0;
    80000ace:	4501                	li	a0,0
    80000ad0:	bfc9                	j	80000aa2 <uvmalloc+0x7a>
    return oldsz;
    80000ad2:	852e                	mv	a0,a1
}
    80000ad4:	8082                	ret
  return newsz;
    80000ad6:	8532                	mv	a0,a2
    80000ad8:	b7e9                	j	80000aa2 <uvmalloc+0x7a>

0000000080000ada <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80000ada:	7179                	addi	sp,sp,-48
    80000adc:	f406                	sd	ra,40(sp)
    80000ade:	f022                	sd	s0,32(sp)
    80000ae0:	ec26                	sd	s1,24(sp)
    80000ae2:	e84a                	sd	s2,16(sp)
    80000ae4:	e44e                	sd	s3,8(sp)
    80000ae6:	e052                	sd	s4,0(sp)
    80000ae8:	1800                	addi	s0,sp,48
    80000aea:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80000aec:	84aa                	mv	s1,a0
    80000aee:	6905                	lui	s2,0x1
    80000af0:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000af2:	4985                	li	s3,1
    80000af4:	a821                	j	80000b0c <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80000af6:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80000af8:	0532                	slli	a0,a0,0xc
    80000afa:	00000097          	auipc	ra,0x0
    80000afe:	fe0080e7          	jalr	-32(ra) # 80000ada <freewalk>
      pagetable[i] = 0;
    80000b02:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80000b06:	04a1                	addi	s1,s1,8
    80000b08:	03248163          	beq	s1,s2,80000b2a <freewalk+0x50>
    pte_t pte = pagetable[i];
    80000b0c:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000b0e:	00f57793          	andi	a5,a0,15
    80000b12:	ff3782e3          	beq	a5,s3,80000af6 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80000b16:	8905                	andi	a0,a0,1
    80000b18:	d57d                	beqz	a0,80000b06 <freewalk+0x2c>
      panic("freewalk: leaf");
    80000b1a:	00007517          	auipc	a0,0x7
    80000b1e:	62e50513          	addi	a0,a0,1582 # 80008148 <etext+0x148>
    80000b22:	00005097          	auipc	ra,0x5
    80000b26:	35c080e7          	jalr	860(ra) # 80005e7e <panic>
    }
  }
  kfree((void*)pagetable);
    80000b2a:	8552                	mv	a0,s4
    80000b2c:	fffff097          	auipc	ra,0xfffff
    80000b30:	4f0080e7          	jalr	1264(ra) # 8000001c <kfree>
}
    80000b34:	70a2                	ld	ra,40(sp)
    80000b36:	7402                	ld	s0,32(sp)
    80000b38:	64e2                	ld	s1,24(sp)
    80000b3a:	6942                	ld	s2,16(sp)
    80000b3c:	69a2                	ld	s3,8(sp)
    80000b3e:	6a02                	ld	s4,0(sp)
    80000b40:	6145                	addi	sp,sp,48
    80000b42:	8082                	ret

0000000080000b44 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80000b44:	1101                	addi	sp,sp,-32
    80000b46:	ec06                	sd	ra,24(sp)
    80000b48:	e822                	sd	s0,16(sp)
    80000b4a:	e426                	sd	s1,8(sp)
    80000b4c:	1000                	addi	s0,sp,32
    80000b4e:	84aa                	mv	s1,a0
  if(sz > 0)
    80000b50:	e999                	bnez	a1,80000b66 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80000b52:	8526                	mv	a0,s1
    80000b54:	00000097          	auipc	ra,0x0
    80000b58:	f86080e7          	jalr	-122(ra) # 80000ada <freewalk>
}
    80000b5c:	60e2                	ld	ra,24(sp)
    80000b5e:	6442                	ld	s0,16(sp)
    80000b60:	64a2                	ld	s1,8(sp)
    80000b62:	6105                	addi	sp,sp,32
    80000b64:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80000b66:	6605                	lui	a2,0x1
    80000b68:	167d                	addi	a2,a2,-1
    80000b6a:	962e                	add	a2,a2,a1
    80000b6c:	4685                	li	a3,1
    80000b6e:	8231                	srli	a2,a2,0xc
    80000b70:	4581                	li	a1,0
    80000b72:	00000097          	auipc	ra,0x0
    80000b76:	d0a080e7          	jalr	-758(ra) # 8000087c <uvmunmap>
    80000b7a:	bfe1                	j	80000b52 <uvmfree+0xe>

0000000080000b7c <uvmcopy>:
//   uvmunmap(new, 0, i / PGSIZE, 1);
//   return -1;
// }

int uvmcopy(pagetable_t old, pagetable_t new, uint64 sz)
{
    80000b7c:	715d                	addi	sp,sp,-80
    80000b7e:	e486                	sd	ra,72(sp)
    80000b80:	e0a2                	sd	s0,64(sp)
    80000b82:	fc26                	sd	s1,56(sp)
    80000b84:	f84a                	sd	s2,48(sp)
    80000b86:	f44e                	sd	s3,40(sp)
    80000b88:	f052                	sd	s4,32(sp)
    80000b8a:	ec56                	sd	s5,24(sp)
    80000b8c:	e85a                	sd	s6,16(sp)
    80000b8e:	e45e                	sd	s7,8(sp)
    80000b90:	0880                	addi	s0,sp,80
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  // void *mem;

  for (i = 0; i < sz; i += PGSIZE)
    80000b92:	ce5d                	beqz	a2,80000c50 <uvmcopy+0xd4>
    80000b94:	8a2a                	mv	s4,a0
    80000b96:	89ae                	mv	s3,a1
    80000b98:	167d                	addi	a2,a2,-1
    80000b9a:	797d                	lui	s2,0xfffff
    80000b9c:	01267933          	and	s2,a2,s2
    80000ba0:	4481                	li	s1,0
  {
    if (i >= MAXVA)
    80000ba2:	4a85                	li	s5,1
    80000ba4:	1a9a                	slli	s5,s5,0x26
      return -1;
    if ((pte = walk(old, i, 0)) == 0)
    80000ba6:	4601                	li	a2,0
    80000ba8:	85a6                	mv	a1,s1
    80000baa:	8552                	mv	a0,s4
    80000bac:	00000097          	auipc	ra,0x0
    80000bb0:	9fe080e7          	jalr	-1538(ra) # 800005aa <walk>
    80000bb4:	c921                	beqz	a0,80000c04 <uvmcopy+0x88>
      panic("uvmcopy: pte should exist");
    if ((*pte & PTE_V) == 0)
    80000bb6:	611c                	ld	a5,0(a0)
    80000bb8:	0017f713          	andi	a4,a5,1
    80000bbc:	cf21                	beqz	a4,80000c14 <uvmcopy+0x98>
      panic("uvmcopy: page not present");
      
    // 修改的内容
    pa = PTE2PA(*pte);
    80000bbe:	00a7db13          	srli	s6,a5,0xa
    80000bc2:	0b32                	slli	s6,s6,0xc
    *pte = (*pte) | (((*pte) & PTE_W) << 6); // pte_cow is equal to original pte_w
    80000bc4:	00679713          	slli	a4,a5,0x6
    80000bc8:	10077713          	andi	a4,a4,256
    80000bcc:	8f5d                	or	a4,a4,a5
    *pte = (*pte) | ((*pte) & PTE_COW);      //set cow_bit if the phy page is already a cow page
    *pte = (*pte) & (~PTE_W);                // clear PTE_W
    80000bce:	9b6d                	andi	a4,a4,-5
    80000bd0:	e118                	sd	a4,0(a0)
    flags = PTE_FLAGS(*pte);                 // get FLAGS
    //
    
    if (mappages(new, i, PGSIZE, pa, flags) != 0)
    80000bd2:	3fb77713          	andi	a4,a4,1019
    80000bd6:	86da                	mv	a3,s6
    80000bd8:	6605                	lui	a2,0x1
    80000bda:	85a6                	mv	a1,s1
    80000bdc:	854e                	mv	a0,s3
    80000bde:	00000097          	auipc	ra,0x0
    80000be2:	ab4080e7          	jalr	-1356(ra) # 80000692 <mappages>
    80000be6:	8baa                	mv	s7,a0
    80000be8:	ed15                	bnez	a0,80000c24 <uvmcopy+0xa8>
    {
      goto err;
    }
    add_refer(pa);
    80000bea:	855a                	mv	a0,s6
    80000bec:	fffff097          	auipc	ra,0xfffff
    80000bf0:	66c080e7          	jalr	1644(ra) # 80000258 <add_refer>
  for (i = 0; i < sz; i += PGSIZE)
    80000bf4:	05248263          	beq	s1,s2,80000c38 <uvmcopy+0xbc>
    if (i >= MAXVA)
    80000bf8:	6785                	lui	a5,0x1
    80000bfa:	94be                	add	s1,s1,a5
    80000bfc:	fb5495e3          	bne	s1,s5,80000ba6 <uvmcopy+0x2a>
      return -1;
    80000c00:	5bfd                	li	s7,-1
    80000c02:	a81d                	j	80000c38 <uvmcopy+0xbc>
      panic("uvmcopy: pte should exist");
    80000c04:	00007517          	auipc	a0,0x7
    80000c08:	55450513          	addi	a0,a0,1364 # 80008158 <etext+0x158>
    80000c0c:	00005097          	auipc	ra,0x5
    80000c10:	272080e7          	jalr	626(ra) # 80005e7e <panic>
      panic("uvmcopy: page not present");
    80000c14:	00007517          	auipc	a0,0x7
    80000c18:	56450513          	addi	a0,a0,1380 # 80008178 <etext+0x178>
    80000c1c:	00005097          	auipc	ra,0x5
    80000c20:	262080e7          	jalr	610(ra) # 80005e7e <panic>
  }
  return 0;

err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80000c24:	4685                	li	a3,1
    80000c26:	00c4d613          	srli	a2,s1,0xc
    80000c2a:	4581                	li	a1,0
    80000c2c:	854e                	mv	a0,s3
    80000c2e:	00000097          	auipc	ra,0x0
    80000c32:	c4e080e7          	jalr	-946(ra) # 8000087c <uvmunmap>
  return -1;
    80000c36:	5bfd                	li	s7,-1
}
    80000c38:	855e                	mv	a0,s7
    80000c3a:	60a6                	ld	ra,72(sp)
    80000c3c:	6406                	ld	s0,64(sp)
    80000c3e:	74e2                	ld	s1,56(sp)
    80000c40:	7942                	ld	s2,48(sp)
    80000c42:	79a2                	ld	s3,40(sp)
    80000c44:	7a02                	ld	s4,32(sp)
    80000c46:	6ae2                	ld	s5,24(sp)
    80000c48:	6b42                	ld	s6,16(sp)
    80000c4a:	6ba2                	ld	s7,8(sp)
    80000c4c:	6161                	addi	sp,sp,80
    80000c4e:	8082                	ret
  return 0;
    80000c50:	4b81                	li	s7,0
    80000c52:	b7dd                	j	80000c38 <uvmcopy+0xbc>

0000000080000c54 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80000c54:	1141                	addi	sp,sp,-16
    80000c56:	e406                	sd	ra,8(sp)
    80000c58:	e022                	sd	s0,0(sp)
    80000c5a:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80000c5c:	4601                	li	a2,0
    80000c5e:	00000097          	auipc	ra,0x0
    80000c62:	94c080e7          	jalr	-1716(ra) # 800005aa <walk>
  if(pte == 0)
    80000c66:	c901                	beqz	a0,80000c76 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80000c68:	611c                	ld	a5,0(a0)
    80000c6a:	9bbd                	andi	a5,a5,-17
    80000c6c:	e11c                	sd	a5,0(a0)
}
    80000c6e:	60a2                	ld	ra,8(sp)
    80000c70:	6402                	ld	s0,0(sp)
    80000c72:	0141                	addi	sp,sp,16
    80000c74:	8082                	ret
    panic("uvmclear");
    80000c76:	00007517          	auipc	a0,0x7
    80000c7a:	52250513          	addi	a0,a0,1314 # 80008198 <etext+0x198>
    80000c7e:	00005097          	auipc	ra,0x5
    80000c82:	200080e7          	jalr	512(ra) # 80005e7e <panic>

0000000080000c86 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80000c86:	caa5                	beqz	a3,80000cf6 <copyin+0x70>
{
    80000c88:	715d                	addi	sp,sp,-80
    80000c8a:	e486                	sd	ra,72(sp)
    80000c8c:	e0a2                	sd	s0,64(sp)
    80000c8e:	fc26                	sd	s1,56(sp)
    80000c90:	f84a                	sd	s2,48(sp)
    80000c92:	f44e                	sd	s3,40(sp)
    80000c94:	f052                	sd	s4,32(sp)
    80000c96:	ec56                	sd	s5,24(sp)
    80000c98:	e85a                	sd	s6,16(sp)
    80000c9a:	e45e                	sd	s7,8(sp)
    80000c9c:	e062                	sd	s8,0(sp)
    80000c9e:	0880                	addi	s0,sp,80
    80000ca0:	8b2a                	mv	s6,a0
    80000ca2:	8a2e                	mv	s4,a1
    80000ca4:	8c32                	mv	s8,a2
    80000ca6:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80000ca8:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000caa:	6a85                	lui	s5,0x1
    80000cac:	a01d                	j	80000cd2 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80000cae:	018505b3          	add	a1,a0,s8
    80000cb2:	0004861b          	sext.w	a2,s1
    80000cb6:	412585b3          	sub	a1,a1,s2
    80000cba:	8552                	mv	a0,s4
    80000cbc:	fffff097          	auipc	ra,0xfffff
    80000cc0:	666080e7          	jalr	1638(ra) # 80000322 <memmove>

    len -= n;
    80000cc4:	409989b3          	sub	s3,s3,s1
    dst += n;
    80000cc8:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80000cca:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80000cce:	02098263          	beqz	s3,80000cf2 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80000cd2:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80000cd6:	85ca                	mv	a1,s2
    80000cd8:	855a                	mv	a0,s6
    80000cda:	00000097          	auipc	ra,0x0
    80000cde:	976080e7          	jalr	-1674(ra) # 80000650 <walkaddr>
    if(pa0 == 0)
    80000ce2:	cd01                	beqz	a0,80000cfa <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80000ce4:	418904b3          	sub	s1,s2,s8
    80000ce8:	94d6                	add	s1,s1,s5
    if(n > len)
    80000cea:	fc99f2e3          	bgeu	s3,s1,80000cae <copyin+0x28>
    80000cee:	84ce                	mv	s1,s3
    80000cf0:	bf7d                	j	80000cae <copyin+0x28>
  }
  return 0;
    80000cf2:	4501                	li	a0,0
    80000cf4:	a021                	j	80000cfc <copyin+0x76>
    80000cf6:	4501                	li	a0,0
}
    80000cf8:	8082                	ret
      return -1;
    80000cfa:	557d                	li	a0,-1
}
    80000cfc:	60a6                	ld	ra,72(sp)
    80000cfe:	6406                	ld	s0,64(sp)
    80000d00:	74e2                	ld	s1,56(sp)
    80000d02:	7942                	ld	s2,48(sp)
    80000d04:	79a2                	ld	s3,40(sp)
    80000d06:	7a02                	ld	s4,32(sp)
    80000d08:	6ae2                	ld	s5,24(sp)
    80000d0a:	6b42                	ld	s6,16(sp)
    80000d0c:	6ba2                	ld	s7,8(sp)
    80000d0e:	6c02                	ld	s8,0(sp)
    80000d10:	6161                	addi	sp,sp,80
    80000d12:	8082                	ret

0000000080000d14 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80000d14:	c6c5                	beqz	a3,80000dbc <copyinstr+0xa8>
{
    80000d16:	715d                	addi	sp,sp,-80
    80000d18:	e486                	sd	ra,72(sp)
    80000d1a:	e0a2                	sd	s0,64(sp)
    80000d1c:	fc26                	sd	s1,56(sp)
    80000d1e:	f84a                	sd	s2,48(sp)
    80000d20:	f44e                	sd	s3,40(sp)
    80000d22:	f052                	sd	s4,32(sp)
    80000d24:	ec56                	sd	s5,24(sp)
    80000d26:	e85a                	sd	s6,16(sp)
    80000d28:	e45e                	sd	s7,8(sp)
    80000d2a:	0880                	addi	s0,sp,80
    80000d2c:	8a2a                	mv	s4,a0
    80000d2e:	8b2e                	mv	s6,a1
    80000d30:	8bb2                	mv	s7,a2
    80000d32:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80000d34:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000d36:	6985                	lui	s3,0x1
    80000d38:	a035                	j	80000d64 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80000d3a:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80000d3e:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80000d40:	0017b793          	seqz	a5,a5
    80000d44:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80000d48:	60a6                	ld	ra,72(sp)
    80000d4a:	6406                	ld	s0,64(sp)
    80000d4c:	74e2                	ld	s1,56(sp)
    80000d4e:	7942                	ld	s2,48(sp)
    80000d50:	79a2                	ld	s3,40(sp)
    80000d52:	7a02                	ld	s4,32(sp)
    80000d54:	6ae2                	ld	s5,24(sp)
    80000d56:	6b42                	ld	s6,16(sp)
    80000d58:	6ba2                	ld	s7,8(sp)
    80000d5a:	6161                	addi	sp,sp,80
    80000d5c:	8082                	ret
    srcva = va0 + PGSIZE;
    80000d5e:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80000d62:	c8a9                	beqz	s1,80000db4 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80000d64:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80000d68:	85ca                	mv	a1,s2
    80000d6a:	8552                	mv	a0,s4
    80000d6c:	00000097          	auipc	ra,0x0
    80000d70:	8e4080e7          	jalr	-1820(ra) # 80000650 <walkaddr>
    if(pa0 == 0)
    80000d74:	c131                	beqz	a0,80000db8 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80000d76:	41790833          	sub	a6,s2,s7
    80000d7a:	984e                	add	a6,a6,s3
    if(n > max)
    80000d7c:	0104f363          	bgeu	s1,a6,80000d82 <copyinstr+0x6e>
    80000d80:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80000d82:	955e                	add	a0,a0,s7
    80000d84:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80000d88:	fc080be3          	beqz	a6,80000d5e <copyinstr+0x4a>
    80000d8c:	985a                	add	a6,a6,s6
    80000d8e:	87da                	mv	a5,s6
      if(*p == '\0'){
    80000d90:	41650633          	sub	a2,a0,s6
    80000d94:	14fd                	addi	s1,s1,-1
    80000d96:	9b26                	add	s6,s6,s1
    80000d98:	00f60733          	add	a4,a2,a5
    80000d9c:	00074703          	lbu	a4,0(a4)
    80000da0:	df49                	beqz	a4,80000d3a <copyinstr+0x26>
        *dst = *p;
    80000da2:	00e78023          	sb	a4,0(a5)
      --max;
    80000da6:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80000daa:	0785                	addi	a5,a5,1
    while(n > 0){
    80000dac:	ff0796e3          	bne	a5,a6,80000d98 <copyinstr+0x84>
      dst++;
    80000db0:	8b42                	mv	s6,a6
    80000db2:	b775                	j	80000d5e <copyinstr+0x4a>
    80000db4:	4781                	li	a5,0
    80000db6:	b769                	j	80000d40 <copyinstr+0x2c>
      return -1;
    80000db8:	557d                	li	a0,-1
    80000dba:	b779                	j	80000d48 <copyinstr+0x34>
  int got_null = 0;
    80000dbc:	4781                	li	a5,0
  if(got_null){
    80000dbe:	0017b793          	seqz	a5,a5
    80000dc2:	40f00533          	neg	a0,a5
}
    80000dc6:	8082                	ret

0000000080000dc8 <cow_copy>:

uint64 cow_copy(pagetable_t pg, uint64 va)
{
  uint64 pa = 0;
  if (va >= MAXVA)
    80000dc8:	57fd                	li	a5,-1
    80000dca:	83e9                	srli	a5,a5,0x1a
    80000dcc:	00b7f463          	bgeu	a5,a1,80000dd4 <cow_copy+0xc>
    return 0;
    80000dd0:	4501                	li	a0,0
    *pte = *pte & (~PTE_V); // why clear PTE_V? avoid remap warning
    mappages(pg, PGROUNDDOWN(va), PGSIZE, (uint64)mem, flag);
    kfree((void *)pa);
  }
  return (uint64)mem;
    80000dd2:	8082                	ret
{
    80000dd4:	7139                	addi	sp,sp,-64
    80000dd6:	fc06                	sd	ra,56(sp)
    80000dd8:	f822                	sd	s0,48(sp)
    80000dda:	f426                	sd	s1,40(sp)
    80000ddc:	f04a                	sd	s2,32(sp)
    80000dde:	ec4e                	sd	s3,24(sp)
    80000de0:	e852                	sd	s4,16(sp)
    80000de2:	e456                	sd	s5,8(sp)
    80000de4:	0080                	addi	s0,sp,64
    80000de6:	8a2a                	mv	s4,a0
    80000de8:	84ae                	mv	s1,a1
  pte_t *pte = walk(pg, va, 0);
    80000dea:	4601                	li	a2,0
    80000dec:	fffff097          	auipc	ra,0xfffff
    80000df0:	7be080e7          	jalr	1982(ra) # 800005aa <walk>
    80000df4:	89aa                	mv	s3,a0
  if ((*pte & PTE_COW) && (*pte & PTE_V))
    80000df6:	6108                	ld	a0,0(a0)
    80000df8:	10157713          	andi	a4,a0,257
    80000dfc:	10100793          	li	a5,257
  void *mem = 0;
    80000e00:	4901                	li	s2,0
  if ((*pte & PTE_COW) && (*pte & PTE_V))
    80000e02:	00f70c63          	beq	a4,a5,80000e1a <cow_copy+0x52>
  return (uint64)mem;
    80000e06:	854a                	mv	a0,s2
    80000e08:	70e2                	ld	ra,56(sp)
    80000e0a:	7442                	ld	s0,48(sp)
    80000e0c:	74a2                	ld	s1,40(sp)
    80000e0e:	7902                	ld	s2,32(sp)
    80000e10:	69e2                	ld	s3,24(sp)
    80000e12:	6a42                	ld	s4,16(sp)
    80000e14:	6aa2                	ld	s5,8(sp)
    80000e16:	6121                	addi	sp,sp,64
    80000e18:	8082                	ret
    pa = PTE2PA(*pte);
    80000e1a:	8129                	srli	a0,a0,0xa
    80000e1c:	00c51a93          	slli	s5,a0,0xc
    if ((mem = kalloc()) == 0)
    80000e20:	fffff097          	auipc	ra,0xfffff
    80000e24:	3a6080e7          	jalr	934(ra) # 800001c6 <kalloc>
    80000e28:	892a                	mv	s2,a0
    80000e2a:	c121                	beqz	a0,80000e6a <cow_copy+0xa2>
    memmove((void *)mem, (void *)pa, PGSIZE);
    80000e2c:	6605                	lui	a2,0x1
    80000e2e:	85d6                	mv	a1,s5
    80000e30:	fffff097          	auipc	ra,0xfffff
    80000e34:	4f2080e7          	jalr	1266(ra) # 80000322 <memmove>
    uint flag = PTE_FLAGS(*pte);
    80000e38:	0009b703          	ld	a4,0(s3) # 1000 <_entry-0x7ffff000>
    *pte = *pte & (~PTE_V); // why clear PTE_V? avoid remap warning
    80000e3c:	ffe77793          	andi	a5,a4,-2
    80000e40:	00f9b023          	sd	a5,0(s3)
    flag = flag & (~PTE_COW);
    80000e44:	2ff77713          	andi	a4,a4,767
    mappages(pg, PGROUNDDOWN(va), PGSIZE, (uint64)mem, flag);
    80000e48:	00476713          	ori	a4,a4,4
    80000e4c:	86ca                	mv	a3,s2
    80000e4e:	6605                	lui	a2,0x1
    80000e50:	75fd                	lui	a1,0xfffff
    80000e52:	8de5                	and	a1,a1,s1
    80000e54:	8552                	mv	a0,s4
    80000e56:	00000097          	auipc	ra,0x0
    80000e5a:	83c080e7          	jalr	-1988(ra) # 80000692 <mappages>
    kfree((void *)pa);
    80000e5e:	8556                	mv	a0,s5
    80000e60:	fffff097          	auipc	ra,0xfffff
    80000e64:	1bc080e7          	jalr	444(ra) # 8000001c <kfree>
    80000e68:	bf79                	j	80000e06 <cow_copy+0x3e>
      panic("cow:no more memory\n");
    80000e6a:	00007517          	auipc	a0,0x7
    80000e6e:	33e50513          	addi	a0,a0,830 # 800081a8 <etext+0x1a8>
    80000e72:	00005097          	auipc	ra,0x5
    80000e76:	00c080e7          	jalr	12(ra) # 80005e7e <panic>

0000000080000e7a <copyout>:
  while (len > 0)
    80000e7a:	c2e9                	beqz	a3,80000f3c <copyout+0xc2>
{
    80000e7c:	7159                	addi	sp,sp,-112
    80000e7e:	f486                	sd	ra,104(sp)
    80000e80:	f0a2                	sd	s0,96(sp)
    80000e82:	eca6                	sd	s1,88(sp)
    80000e84:	e8ca                	sd	s2,80(sp)
    80000e86:	e4ce                	sd	s3,72(sp)
    80000e88:	e0d2                	sd	s4,64(sp)
    80000e8a:	fc56                	sd	s5,56(sp)
    80000e8c:	f85a                	sd	s6,48(sp)
    80000e8e:	f45e                	sd	s7,40(sp)
    80000e90:	f062                	sd	s8,32(sp)
    80000e92:	ec66                	sd	s9,24(sp)
    80000e94:	e86a                	sd	s10,16(sp)
    80000e96:	e46e                	sd	s11,8(sp)
    80000e98:	1880                	addi	s0,sp,112
    80000e9a:	8baa                	mv	s7,a0
    80000e9c:	8aae                	mv	s5,a1
    80000e9e:	8b32                	mv	s6,a2
    80000ea0:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80000ea2:	74fd                	lui	s1,0xfffff
    80000ea4:	8ced                	and	s1,s1,a1
    if (va0 >= MAXVA)
    80000ea6:	57fd                	li	a5,-1
    80000ea8:	83e9                	srli	a5,a5,0x1a
    80000eaa:	0897eb63          	bltu	a5,s1,80000f40 <copyout+0xc6>
    if (pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    80000eae:	4cc5                	li	s9,17
    else if ((*pte & PTE_W) == 0 && (*pte & PTE_COW) != 0)// 如果是cow页就申请一个新的物理页
    80000eb0:	10000d13          	li	s10,256
    80000eb4:	6d85                	lui	s11,0x1
    if (va0 >= MAXVA)
    80000eb6:	8c3e                	mv	s8,a5
    80000eb8:	a0b1                	j	80000f04 <copyout+0x8a>
      if (cow_copy(pagetable, dstva) != 0)
    80000eba:	85d6                	mv	a1,s5
    80000ebc:	855e                	mv	a0,s7
    80000ebe:	00000097          	auipc	ra,0x0
    80000ec2:	f0a080e7          	jalr	-246(ra) # 80000dc8 <cow_copy>
    80000ec6:	c54d                	beqz	a0,80000f70 <copyout+0xf6>
        pte = walk(pagetable, va0, 0);
    80000ec8:	4601                	li	a2,0
    80000eca:	85a6                	mv	a1,s1
    80000ecc:	855e                	mv	a0,s7
    80000ece:	fffff097          	auipc	ra,0xfffff
    80000ed2:	6dc080e7          	jalr	1756(ra) # 800005aa <walk>
    80000ed6:	a889                	j	80000f28 <copyout+0xae>
    pa0 = PTE2PA(*pte);
    80000ed8:	611c                	ld	a5,0(a0)
    80000eda:	83a9                	srli	a5,a5,0xa
    80000edc:	07b2                	slli	a5,a5,0xc
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80000ede:	409a8533          	sub	a0,s5,s1
    80000ee2:	0009061b          	sext.w	a2,s2
    80000ee6:	85da                	mv	a1,s6
    80000ee8:	953e                	add	a0,a0,a5
    80000eea:	fffff097          	auipc	ra,0xfffff
    80000eee:	438080e7          	jalr	1080(ra) # 80000322 <memmove>
    len -= n;
    80000ef2:	412989b3          	sub	s3,s3,s2
    src += n;
    80000ef6:	9b4a                	add	s6,s6,s2
  while (len > 0)
    80000ef8:	04098063          	beqz	s3,80000f38 <copyout+0xbe>
    if (va0 >= MAXVA)
    80000efc:	054c6463          	bltu	s8,s4,80000f44 <copyout+0xca>
    va0 = PGROUNDDOWN(dstva);
    80000f00:	84d2                	mv	s1,s4
    dstva = va0 + PGSIZE;
    80000f02:	8ad2                	mv	s5,s4
    pte = walk(pagetable, va0, 0);
    80000f04:	4601                	li	a2,0
    80000f06:	85a6                	mv	a1,s1
    80000f08:	855e                	mv	a0,s7
    80000f0a:	fffff097          	auipc	ra,0xfffff
    80000f0e:	6a0080e7          	jalr	1696(ra) # 800005aa <walk>
    if (pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    80000f12:	c91d                	beqz	a0,80000f48 <copyout+0xce>
    80000f14:	611c                	ld	a5,0(a0)
    80000f16:	0117f713          	andi	a4,a5,17
    80000f1a:	05971763          	bne	a4,s9,80000f68 <copyout+0xee>
        ((*pte & PTE_W) == 0 && (*pte & PTE_COW) == 0))
    80000f1e:	1047f793          	andi	a5,a5,260
    if (pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    80000f22:	c7a9                	beqz	a5,80000f6c <copyout+0xf2>
    else if ((*pte & PTE_W) == 0 && (*pte & PTE_COW) != 0)// 如果是cow页就申请一个新的物理页
    80000f24:	f9a78be3          	beq	a5,s10,80000eba <copyout+0x40>
    n = PGSIZE - (dstva - va0);
    80000f28:	01b48a33          	add	s4,s1,s11
    80000f2c:	415a0933          	sub	s2,s4,s5
    if (n > len)
    80000f30:	fb29f4e3          	bgeu	s3,s2,80000ed8 <copyout+0x5e>
    80000f34:	894e                	mv	s2,s3
    80000f36:	b74d                	j	80000ed8 <copyout+0x5e>
  return 0;
    80000f38:	4501                	li	a0,0
    80000f3a:	a801                	j	80000f4a <copyout+0xd0>
    80000f3c:	4501                	li	a0,0
}
    80000f3e:	8082                	ret
      return -1;
    80000f40:	557d                	li	a0,-1
    80000f42:	a021                	j	80000f4a <copyout+0xd0>
    80000f44:	557d                	li	a0,-1
    80000f46:	a011                	j	80000f4a <copyout+0xd0>
      return -1;
    80000f48:	557d                	li	a0,-1
}
    80000f4a:	70a6                	ld	ra,104(sp)
    80000f4c:	7406                	ld	s0,96(sp)
    80000f4e:	64e6                	ld	s1,88(sp)
    80000f50:	6946                	ld	s2,80(sp)
    80000f52:	69a6                	ld	s3,72(sp)
    80000f54:	6a06                	ld	s4,64(sp)
    80000f56:	7ae2                	ld	s5,56(sp)
    80000f58:	7b42                	ld	s6,48(sp)
    80000f5a:	7ba2                	ld	s7,40(sp)
    80000f5c:	7c02                	ld	s8,32(sp)
    80000f5e:	6ce2                	ld	s9,24(sp)
    80000f60:	6d42                	ld	s10,16(sp)
    80000f62:	6da2                	ld	s11,8(sp)
    80000f64:	6165                	addi	sp,sp,112
    80000f66:	8082                	ret
      return -1;
    80000f68:	557d                	li	a0,-1
    80000f6a:	b7c5                	j	80000f4a <copyout+0xd0>
    80000f6c:	557d                	li	a0,-1
    80000f6e:	bff1                	j	80000f4a <copyout+0xd0>
        return -1;
    80000f70:	557d                	li	a0,-1
    80000f72:	bfe1                	j	80000f4a <copyout+0xd0>

0000000080000f74 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80000f74:	7139                	addi	sp,sp,-64
    80000f76:	fc06                	sd	ra,56(sp)
    80000f78:	f822                	sd	s0,48(sp)
    80000f7a:	f426                	sd	s1,40(sp)
    80000f7c:	f04a                	sd	s2,32(sp)
    80000f7e:	ec4e                	sd	s3,24(sp)
    80000f80:	e852                	sd	s4,16(sp)
    80000f82:	e456                	sd	s5,8(sp)
    80000f84:	e05a                	sd	s6,0(sp)
    80000f86:	0080                	addi	s0,sp,64
    80000f88:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80000f8a:	00108497          	auipc	s1,0x108
    80000f8e:	f3648493          	addi	s1,s1,-202 # 80108ec0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80000f92:	8b26                	mv	s6,s1
    80000f94:	00007a97          	auipc	s5,0x7
    80000f98:	06ca8a93          	addi	s5,s5,108 # 80008000 <etext>
    80000f9c:	04000937          	lui	s2,0x4000
    80000fa0:	197d                	addi	s2,s2,-1
    80000fa2:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000fa4:	0010ea17          	auipc	s4,0x10e
    80000fa8:	91ca0a13          	addi	s4,s4,-1764 # 8010e8c0 <tickslock>
    char *pa = kalloc();
    80000fac:	fffff097          	auipc	ra,0xfffff
    80000fb0:	21a080e7          	jalr	538(ra) # 800001c6 <kalloc>
    80000fb4:	862a                	mv	a2,a0
    if(pa == 0)
    80000fb6:	c131                	beqz	a0,80000ffa <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80000fb8:	416485b3          	sub	a1,s1,s6
    80000fbc:	858d                	srai	a1,a1,0x3
    80000fbe:	000ab783          	ld	a5,0(s5)
    80000fc2:	02f585b3          	mul	a1,a1,a5
    80000fc6:	2585                	addiw	a1,a1,1
    80000fc8:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80000fcc:	4719                	li	a4,6
    80000fce:	6685                	lui	a3,0x1
    80000fd0:	40b905b3          	sub	a1,s2,a1
    80000fd4:	854e                	mv	a0,s3
    80000fd6:	fffff097          	auipc	ra,0xfffff
    80000fda:	780080e7          	jalr	1920(ra) # 80000756 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000fde:	16848493          	addi	s1,s1,360
    80000fe2:	fd4495e3          	bne	s1,s4,80000fac <proc_mapstacks+0x38>
  }
}
    80000fe6:	70e2                	ld	ra,56(sp)
    80000fe8:	7442                	ld	s0,48(sp)
    80000fea:	74a2                	ld	s1,40(sp)
    80000fec:	7902                	ld	s2,32(sp)
    80000fee:	69e2                	ld	s3,24(sp)
    80000ff0:	6a42                	ld	s4,16(sp)
    80000ff2:	6aa2                	ld	s5,8(sp)
    80000ff4:	6b02                	ld	s6,0(sp)
    80000ff6:	6121                	addi	sp,sp,64
    80000ff8:	8082                	ret
      panic("kalloc");
    80000ffa:	00007517          	auipc	a0,0x7
    80000ffe:	1c650513          	addi	a0,a0,454 # 800081c0 <etext+0x1c0>
    80001002:	00005097          	auipc	ra,0x5
    80001006:	e7c080e7          	jalr	-388(ra) # 80005e7e <panic>

000000008000100a <procinit>:

// initialize the proc table.
void
procinit(void)
{
    8000100a:	7139                	addi	sp,sp,-64
    8000100c:	fc06                	sd	ra,56(sp)
    8000100e:	f822                	sd	s0,48(sp)
    80001010:	f426                	sd	s1,40(sp)
    80001012:	f04a                	sd	s2,32(sp)
    80001014:	ec4e                	sd	s3,24(sp)
    80001016:	e852                	sd	s4,16(sp)
    80001018:	e456                	sd	s5,8(sp)
    8000101a:	e05a                	sd	s6,0(sp)
    8000101c:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    8000101e:	00007597          	auipc	a1,0x7
    80001022:	1aa58593          	addi	a1,a1,426 # 800081c8 <etext+0x1c8>
    80001026:	00108517          	auipc	a0,0x108
    8000102a:	a6a50513          	addi	a0,a0,-1430 # 80108a90 <pid_lock>
    8000102e:	00005097          	auipc	ra,0x5
    80001032:	2fc080e7          	jalr	764(ra) # 8000632a <initlock>
  initlock(&wait_lock, "wait_lock");
    80001036:	00007597          	auipc	a1,0x7
    8000103a:	19a58593          	addi	a1,a1,410 # 800081d0 <etext+0x1d0>
    8000103e:	00108517          	auipc	a0,0x108
    80001042:	a6a50513          	addi	a0,a0,-1430 # 80108aa8 <wait_lock>
    80001046:	00005097          	auipc	ra,0x5
    8000104a:	2e4080e7          	jalr	740(ra) # 8000632a <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000104e:	00108497          	auipc	s1,0x108
    80001052:	e7248493          	addi	s1,s1,-398 # 80108ec0 <proc>
      initlock(&p->lock, "proc");
    80001056:	00007b17          	auipc	s6,0x7
    8000105a:	18ab0b13          	addi	s6,s6,394 # 800081e0 <etext+0x1e0>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000105e:	8aa6                	mv	s5,s1
    80001060:	00007a17          	auipc	s4,0x7
    80001064:	fa0a0a13          	addi	s4,s4,-96 # 80008000 <etext>
    80001068:	04000937          	lui	s2,0x4000
    8000106c:	197d                	addi	s2,s2,-1
    8000106e:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001070:	0010e997          	auipc	s3,0x10e
    80001074:	85098993          	addi	s3,s3,-1968 # 8010e8c0 <tickslock>
      initlock(&p->lock, "proc");
    80001078:	85da                	mv	a1,s6
    8000107a:	8526                	mv	a0,s1
    8000107c:	00005097          	auipc	ra,0x5
    80001080:	2ae080e7          	jalr	686(ra) # 8000632a <initlock>
      p->state = UNUSED;
    80001084:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001088:	415487b3          	sub	a5,s1,s5
    8000108c:	878d                	srai	a5,a5,0x3
    8000108e:	000a3703          	ld	a4,0(s4)
    80001092:	02e787b3          	mul	a5,a5,a4
    80001096:	2785                	addiw	a5,a5,1
    80001098:	00d7979b          	slliw	a5,a5,0xd
    8000109c:	40f907b3          	sub	a5,s2,a5
    800010a0:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800010a2:	16848493          	addi	s1,s1,360
    800010a6:	fd3499e3          	bne	s1,s3,80001078 <procinit+0x6e>
  }
}
    800010aa:	70e2                	ld	ra,56(sp)
    800010ac:	7442                	ld	s0,48(sp)
    800010ae:	74a2                	ld	s1,40(sp)
    800010b0:	7902                	ld	s2,32(sp)
    800010b2:	69e2                	ld	s3,24(sp)
    800010b4:	6a42                	ld	s4,16(sp)
    800010b6:	6aa2                	ld	s5,8(sp)
    800010b8:	6b02                	ld	s6,0(sp)
    800010ba:	6121                	addi	sp,sp,64
    800010bc:	8082                	ret

00000000800010be <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800010be:	1141                	addi	sp,sp,-16
    800010c0:	e422                	sd	s0,8(sp)
    800010c2:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800010c4:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800010c6:	2501                	sext.w	a0,a0
    800010c8:	6422                	ld	s0,8(sp)
    800010ca:	0141                	addi	sp,sp,16
    800010cc:	8082                	ret

00000000800010ce <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800010ce:	1141                	addi	sp,sp,-16
    800010d0:	e422                	sd	s0,8(sp)
    800010d2:	0800                	addi	s0,sp,16
    800010d4:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800010d6:	2781                	sext.w	a5,a5
    800010d8:	079e                	slli	a5,a5,0x7
  return c;
}
    800010da:	00108517          	auipc	a0,0x108
    800010de:	9e650513          	addi	a0,a0,-1562 # 80108ac0 <cpus>
    800010e2:	953e                	add	a0,a0,a5
    800010e4:	6422                	ld	s0,8(sp)
    800010e6:	0141                	addi	sp,sp,16
    800010e8:	8082                	ret

00000000800010ea <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800010ea:	1101                	addi	sp,sp,-32
    800010ec:	ec06                	sd	ra,24(sp)
    800010ee:	e822                	sd	s0,16(sp)
    800010f0:	e426                	sd	s1,8(sp)
    800010f2:	1000                	addi	s0,sp,32
  push_off();
    800010f4:	00005097          	auipc	ra,0x5
    800010f8:	27a080e7          	jalr	634(ra) # 8000636e <push_off>
    800010fc:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800010fe:	2781                	sext.w	a5,a5
    80001100:	079e                	slli	a5,a5,0x7
    80001102:	00108717          	auipc	a4,0x108
    80001106:	98e70713          	addi	a4,a4,-1650 # 80108a90 <pid_lock>
    8000110a:	97ba                	add	a5,a5,a4
    8000110c:	7b84                	ld	s1,48(a5)
  pop_off();
    8000110e:	00005097          	auipc	ra,0x5
    80001112:	300080e7          	jalr	768(ra) # 8000640e <pop_off>
  return p;
}
    80001116:	8526                	mv	a0,s1
    80001118:	60e2                	ld	ra,24(sp)
    8000111a:	6442                	ld	s0,16(sp)
    8000111c:	64a2                	ld	s1,8(sp)
    8000111e:	6105                	addi	sp,sp,32
    80001120:	8082                	ret

0000000080001122 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001122:	1141                	addi	sp,sp,-16
    80001124:	e406                	sd	ra,8(sp)
    80001126:	e022                	sd	s0,0(sp)
    80001128:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    8000112a:	00000097          	auipc	ra,0x0
    8000112e:	fc0080e7          	jalr	-64(ra) # 800010ea <myproc>
    80001132:	00005097          	auipc	ra,0x5
    80001136:	33c080e7          	jalr	828(ra) # 8000646e <release>

  if (first) {
    8000113a:	00007797          	auipc	a5,0x7
    8000113e:	7767a783          	lw	a5,1910(a5) # 800088b0 <first.1>
    80001142:	eb89                	bnez	a5,80001154 <forkret+0x32>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    80001144:	00001097          	auipc	ra,0x1
    80001148:	c5e080e7          	jalr	-930(ra) # 80001da2 <usertrapret>
}
    8000114c:	60a2                	ld	ra,8(sp)
    8000114e:	6402                	ld	s0,0(sp)
    80001150:	0141                	addi	sp,sp,16
    80001152:	8082                	ret
    fsinit(ROOTDEV);
    80001154:	4505                	li	a0,1
    80001156:	00002097          	auipc	ra,0x2
    8000115a:	9fe080e7          	jalr	-1538(ra) # 80002b54 <fsinit>
    first = 0;
    8000115e:	00007797          	auipc	a5,0x7
    80001162:	7407a923          	sw	zero,1874(a5) # 800088b0 <first.1>
    __sync_synchronize();
    80001166:	0ff0000f          	fence
    8000116a:	bfe9                	j	80001144 <forkret+0x22>

000000008000116c <allocpid>:
{
    8000116c:	1101                	addi	sp,sp,-32
    8000116e:	ec06                	sd	ra,24(sp)
    80001170:	e822                	sd	s0,16(sp)
    80001172:	e426                	sd	s1,8(sp)
    80001174:	e04a                	sd	s2,0(sp)
    80001176:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001178:	00108917          	auipc	s2,0x108
    8000117c:	91890913          	addi	s2,s2,-1768 # 80108a90 <pid_lock>
    80001180:	854a                	mv	a0,s2
    80001182:	00005097          	auipc	ra,0x5
    80001186:	238080e7          	jalr	568(ra) # 800063ba <acquire>
  pid = nextpid;
    8000118a:	00007797          	auipc	a5,0x7
    8000118e:	72a78793          	addi	a5,a5,1834 # 800088b4 <nextpid>
    80001192:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001194:	0014871b          	addiw	a4,s1,1
    80001198:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    8000119a:	854a                	mv	a0,s2
    8000119c:	00005097          	auipc	ra,0x5
    800011a0:	2d2080e7          	jalr	722(ra) # 8000646e <release>
}
    800011a4:	8526                	mv	a0,s1
    800011a6:	60e2                	ld	ra,24(sp)
    800011a8:	6442                	ld	s0,16(sp)
    800011aa:	64a2                	ld	s1,8(sp)
    800011ac:	6902                	ld	s2,0(sp)
    800011ae:	6105                	addi	sp,sp,32
    800011b0:	8082                	ret

00000000800011b2 <proc_pagetable>:
{
    800011b2:	1101                	addi	sp,sp,-32
    800011b4:	ec06                	sd	ra,24(sp)
    800011b6:	e822                	sd	s0,16(sp)
    800011b8:	e426                	sd	s1,8(sp)
    800011ba:	e04a                	sd	s2,0(sp)
    800011bc:	1000                	addi	s0,sp,32
    800011be:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    800011c0:	fffff097          	auipc	ra,0xfffff
    800011c4:	780080e7          	jalr	1920(ra) # 80000940 <uvmcreate>
    800011c8:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800011ca:	c121                	beqz	a0,8000120a <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    800011cc:	4729                	li	a4,10
    800011ce:	00006697          	auipc	a3,0x6
    800011d2:	e3268693          	addi	a3,a3,-462 # 80007000 <_trampoline>
    800011d6:	6605                	lui	a2,0x1
    800011d8:	040005b7          	lui	a1,0x4000
    800011dc:	15fd                	addi	a1,a1,-1
    800011de:	05b2                	slli	a1,a1,0xc
    800011e0:	fffff097          	auipc	ra,0xfffff
    800011e4:	4b2080e7          	jalr	1202(ra) # 80000692 <mappages>
    800011e8:	02054863          	bltz	a0,80001218 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    800011ec:	4719                	li	a4,6
    800011ee:	05893683          	ld	a3,88(s2)
    800011f2:	6605                	lui	a2,0x1
    800011f4:	020005b7          	lui	a1,0x2000
    800011f8:	15fd                	addi	a1,a1,-1
    800011fa:	05b6                	slli	a1,a1,0xd
    800011fc:	8526                	mv	a0,s1
    800011fe:	fffff097          	auipc	ra,0xfffff
    80001202:	494080e7          	jalr	1172(ra) # 80000692 <mappages>
    80001206:	02054163          	bltz	a0,80001228 <proc_pagetable+0x76>
}
    8000120a:	8526                	mv	a0,s1
    8000120c:	60e2                	ld	ra,24(sp)
    8000120e:	6442                	ld	s0,16(sp)
    80001210:	64a2                	ld	s1,8(sp)
    80001212:	6902                	ld	s2,0(sp)
    80001214:	6105                	addi	sp,sp,32
    80001216:	8082                	ret
    uvmfree(pagetable, 0);
    80001218:	4581                	li	a1,0
    8000121a:	8526                	mv	a0,s1
    8000121c:	00000097          	auipc	ra,0x0
    80001220:	928080e7          	jalr	-1752(ra) # 80000b44 <uvmfree>
    return 0;
    80001224:	4481                	li	s1,0
    80001226:	b7d5                	j	8000120a <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001228:	4681                	li	a3,0
    8000122a:	4605                	li	a2,1
    8000122c:	040005b7          	lui	a1,0x4000
    80001230:	15fd                	addi	a1,a1,-1
    80001232:	05b2                	slli	a1,a1,0xc
    80001234:	8526                	mv	a0,s1
    80001236:	fffff097          	auipc	ra,0xfffff
    8000123a:	646080e7          	jalr	1606(ra) # 8000087c <uvmunmap>
    uvmfree(pagetable, 0);
    8000123e:	4581                	li	a1,0
    80001240:	8526                	mv	a0,s1
    80001242:	00000097          	auipc	ra,0x0
    80001246:	902080e7          	jalr	-1790(ra) # 80000b44 <uvmfree>
    return 0;
    8000124a:	4481                	li	s1,0
    8000124c:	bf7d                	j	8000120a <proc_pagetable+0x58>

000000008000124e <proc_freepagetable>:
{
    8000124e:	1101                	addi	sp,sp,-32
    80001250:	ec06                	sd	ra,24(sp)
    80001252:	e822                	sd	s0,16(sp)
    80001254:	e426                	sd	s1,8(sp)
    80001256:	e04a                	sd	s2,0(sp)
    80001258:	1000                	addi	s0,sp,32
    8000125a:	84aa                	mv	s1,a0
    8000125c:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    8000125e:	4681                	li	a3,0
    80001260:	4605                	li	a2,1
    80001262:	040005b7          	lui	a1,0x4000
    80001266:	15fd                	addi	a1,a1,-1
    80001268:	05b2                	slli	a1,a1,0xc
    8000126a:	fffff097          	auipc	ra,0xfffff
    8000126e:	612080e7          	jalr	1554(ra) # 8000087c <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001272:	4681                	li	a3,0
    80001274:	4605                	li	a2,1
    80001276:	020005b7          	lui	a1,0x2000
    8000127a:	15fd                	addi	a1,a1,-1
    8000127c:	05b6                	slli	a1,a1,0xd
    8000127e:	8526                	mv	a0,s1
    80001280:	fffff097          	auipc	ra,0xfffff
    80001284:	5fc080e7          	jalr	1532(ra) # 8000087c <uvmunmap>
  uvmfree(pagetable, sz);
    80001288:	85ca                	mv	a1,s2
    8000128a:	8526                	mv	a0,s1
    8000128c:	00000097          	auipc	ra,0x0
    80001290:	8b8080e7          	jalr	-1864(ra) # 80000b44 <uvmfree>
}
    80001294:	60e2                	ld	ra,24(sp)
    80001296:	6442                	ld	s0,16(sp)
    80001298:	64a2                	ld	s1,8(sp)
    8000129a:	6902                	ld	s2,0(sp)
    8000129c:	6105                	addi	sp,sp,32
    8000129e:	8082                	ret

00000000800012a0 <freeproc>:
{
    800012a0:	1101                	addi	sp,sp,-32
    800012a2:	ec06                	sd	ra,24(sp)
    800012a4:	e822                	sd	s0,16(sp)
    800012a6:	e426                	sd	s1,8(sp)
    800012a8:	1000                	addi	s0,sp,32
    800012aa:	84aa                	mv	s1,a0
  if(p->trapframe)
    800012ac:	6d28                	ld	a0,88(a0)
    800012ae:	c509                	beqz	a0,800012b8 <freeproc+0x18>
    kfree((void*)p->trapframe);
    800012b0:	fffff097          	auipc	ra,0xfffff
    800012b4:	d6c080e7          	jalr	-660(ra) # 8000001c <kfree>
  p->trapframe = 0;
    800012b8:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    800012bc:	68a8                	ld	a0,80(s1)
    800012be:	c511                	beqz	a0,800012ca <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    800012c0:	64ac                	ld	a1,72(s1)
    800012c2:	00000097          	auipc	ra,0x0
    800012c6:	f8c080e7          	jalr	-116(ra) # 8000124e <proc_freepagetable>
  p->pagetable = 0;
    800012ca:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    800012ce:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    800012d2:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    800012d6:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    800012da:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    800012de:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    800012e2:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    800012e6:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    800012ea:	0004ac23          	sw	zero,24(s1)
}
    800012ee:	60e2                	ld	ra,24(sp)
    800012f0:	6442                	ld	s0,16(sp)
    800012f2:	64a2                	ld	s1,8(sp)
    800012f4:	6105                	addi	sp,sp,32
    800012f6:	8082                	ret

00000000800012f8 <allocproc>:
{
    800012f8:	1101                	addi	sp,sp,-32
    800012fa:	ec06                	sd	ra,24(sp)
    800012fc:	e822                	sd	s0,16(sp)
    800012fe:	e426                	sd	s1,8(sp)
    80001300:	e04a                	sd	s2,0(sp)
    80001302:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001304:	00108497          	auipc	s1,0x108
    80001308:	bbc48493          	addi	s1,s1,-1092 # 80108ec0 <proc>
    8000130c:	0010d917          	auipc	s2,0x10d
    80001310:	5b490913          	addi	s2,s2,1460 # 8010e8c0 <tickslock>
    acquire(&p->lock);
    80001314:	8526                	mv	a0,s1
    80001316:	00005097          	auipc	ra,0x5
    8000131a:	0a4080e7          	jalr	164(ra) # 800063ba <acquire>
    if(p->state == UNUSED) {
    8000131e:	4c9c                	lw	a5,24(s1)
    80001320:	cf81                	beqz	a5,80001338 <allocproc+0x40>
      release(&p->lock);
    80001322:	8526                	mv	a0,s1
    80001324:	00005097          	auipc	ra,0x5
    80001328:	14a080e7          	jalr	330(ra) # 8000646e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000132c:	16848493          	addi	s1,s1,360
    80001330:	ff2492e3          	bne	s1,s2,80001314 <allocproc+0x1c>
  return 0;
    80001334:	4481                	li	s1,0
    80001336:	a889                	j	80001388 <allocproc+0x90>
  p->pid = allocpid();
    80001338:	00000097          	auipc	ra,0x0
    8000133c:	e34080e7          	jalr	-460(ra) # 8000116c <allocpid>
    80001340:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001342:	4785                	li	a5,1
    80001344:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001346:	fffff097          	auipc	ra,0xfffff
    8000134a:	e80080e7          	jalr	-384(ra) # 800001c6 <kalloc>
    8000134e:	892a                	mv	s2,a0
    80001350:	eca8                	sd	a0,88(s1)
    80001352:	c131                	beqz	a0,80001396 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001354:	8526                	mv	a0,s1
    80001356:	00000097          	auipc	ra,0x0
    8000135a:	e5c080e7          	jalr	-420(ra) # 800011b2 <proc_pagetable>
    8000135e:	892a                	mv	s2,a0
    80001360:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001362:	c531                	beqz	a0,800013ae <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001364:	07000613          	li	a2,112
    80001368:	4581                	li	a1,0
    8000136a:	06048513          	addi	a0,s1,96
    8000136e:	fffff097          	auipc	ra,0xfffff
    80001372:	f58080e7          	jalr	-168(ra) # 800002c6 <memset>
  p->context.ra = (uint64)forkret;
    80001376:	00000797          	auipc	a5,0x0
    8000137a:	dac78793          	addi	a5,a5,-596 # 80001122 <forkret>
    8000137e:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001380:	60bc                	ld	a5,64(s1)
    80001382:	6705                	lui	a4,0x1
    80001384:	97ba                	add	a5,a5,a4
    80001386:	f4bc                	sd	a5,104(s1)
}
    80001388:	8526                	mv	a0,s1
    8000138a:	60e2                	ld	ra,24(sp)
    8000138c:	6442                	ld	s0,16(sp)
    8000138e:	64a2                	ld	s1,8(sp)
    80001390:	6902                	ld	s2,0(sp)
    80001392:	6105                	addi	sp,sp,32
    80001394:	8082                	ret
    freeproc(p);
    80001396:	8526                	mv	a0,s1
    80001398:	00000097          	auipc	ra,0x0
    8000139c:	f08080e7          	jalr	-248(ra) # 800012a0 <freeproc>
    release(&p->lock);
    800013a0:	8526                	mv	a0,s1
    800013a2:	00005097          	auipc	ra,0x5
    800013a6:	0cc080e7          	jalr	204(ra) # 8000646e <release>
    return 0;
    800013aa:	84ca                	mv	s1,s2
    800013ac:	bff1                	j	80001388 <allocproc+0x90>
    freeproc(p);
    800013ae:	8526                	mv	a0,s1
    800013b0:	00000097          	auipc	ra,0x0
    800013b4:	ef0080e7          	jalr	-272(ra) # 800012a0 <freeproc>
    release(&p->lock);
    800013b8:	8526                	mv	a0,s1
    800013ba:	00005097          	auipc	ra,0x5
    800013be:	0b4080e7          	jalr	180(ra) # 8000646e <release>
    return 0;
    800013c2:	84ca                	mv	s1,s2
    800013c4:	b7d1                	j	80001388 <allocproc+0x90>

00000000800013c6 <userinit>:
{
    800013c6:	1101                	addi	sp,sp,-32
    800013c8:	ec06                	sd	ra,24(sp)
    800013ca:	e822                	sd	s0,16(sp)
    800013cc:	e426                	sd	s1,8(sp)
    800013ce:	1000                	addi	s0,sp,32
  p = allocproc();
    800013d0:	00000097          	auipc	ra,0x0
    800013d4:	f28080e7          	jalr	-216(ra) # 800012f8 <allocproc>
    800013d8:	84aa                	mv	s1,a0
  initproc = p;
    800013da:	00007797          	auipc	a5,0x7
    800013de:	52a7bb23          	sd	a0,1334(a5) # 80008910 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    800013e2:	03400613          	li	a2,52
    800013e6:	00007597          	auipc	a1,0x7
    800013ea:	4da58593          	addi	a1,a1,1242 # 800088c0 <initcode>
    800013ee:	6928                	ld	a0,80(a0)
    800013f0:	fffff097          	auipc	ra,0xfffff
    800013f4:	57e080e7          	jalr	1406(ra) # 8000096e <uvmfirst>
  p->sz = PGSIZE;
    800013f8:	6785                	lui	a5,0x1
    800013fa:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    800013fc:	6cb8                	ld	a4,88(s1)
    800013fe:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001402:	6cb8                	ld	a4,88(s1)
    80001404:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001406:	4641                	li	a2,16
    80001408:	00007597          	auipc	a1,0x7
    8000140c:	de058593          	addi	a1,a1,-544 # 800081e8 <etext+0x1e8>
    80001410:	15848513          	addi	a0,s1,344
    80001414:	fffff097          	auipc	ra,0xfffff
    80001418:	ffc080e7          	jalr	-4(ra) # 80000410 <safestrcpy>
  p->cwd = namei("/");
    8000141c:	00007517          	auipc	a0,0x7
    80001420:	ddc50513          	addi	a0,a0,-548 # 800081f8 <etext+0x1f8>
    80001424:	00002097          	auipc	ra,0x2
    80001428:	152080e7          	jalr	338(ra) # 80003576 <namei>
    8000142c:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001430:	478d                	li	a5,3
    80001432:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001434:	8526                	mv	a0,s1
    80001436:	00005097          	auipc	ra,0x5
    8000143a:	038080e7          	jalr	56(ra) # 8000646e <release>
}
    8000143e:	60e2                	ld	ra,24(sp)
    80001440:	6442                	ld	s0,16(sp)
    80001442:	64a2                	ld	s1,8(sp)
    80001444:	6105                	addi	sp,sp,32
    80001446:	8082                	ret

0000000080001448 <growproc>:
{
    80001448:	1101                	addi	sp,sp,-32
    8000144a:	ec06                	sd	ra,24(sp)
    8000144c:	e822                	sd	s0,16(sp)
    8000144e:	e426                	sd	s1,8(sp)
    80001450:	e04a                	sd	s2,0(sp)
    80001452:	1000                	addi	s0,sp,32
    80001454:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001456:	00000097          	auipc	ra,0x0
    8000145a:	c94080e7          	jalr	-876(ra) # 800010ea <myproc>
    8000145e:	84aa                	mv	s1,a0
  sz = p->sz;
    80001460:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001462:	01204c63          	bgtz	s2,8000147a <growproc+0x32>
  } else if(n < 0){
    80001466:	02094663          	bltz	s2,80001492 <growproc+0x4a>
  p->sz = sz;
    8000146a:	e4ac                	sd	a1,72(s1)
  return 0;
    8000146c:	4501                	li	a0,0
}
    8000146e:	60e2                	ld	ra,24(sp)
    80001470:	6442                	ld	s0,16(sp)
    80001472:	64a2                	ld	s1,8(sp)
    80001474:	6902                	ld	s2,0(sp)
    80001476:	6105                	addi	sp,sp,32
    80001478:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    8000147a:	4691                	li	a3,4
    8000147c:	00b90633          	add	a2,s2,a1
    80001480:	6928                	ld	a0,80(a0)
    80001482:	fffff097          	auipc	ra,0xfffff
    80001486:	5a6080e7          	jalr	1446(ra) # 80000a28 <uvmalloc>
    8000148a:	85aa                	mv	a1,a0
    8000148c:	fd79                	bnez	a0,8000146a <growproc+0x22>
      return -1;
    8000148e:	557d                	li	a0,-1
    80001490:	bff9                	j	8000146e <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001492:	00b90633          	add	a2,s2,a1
    80001496:	6928                	ld	a0,80(a0)
    80001498:	fffff097          	auipc	ra,0xfffff
    8000149c:	548080e7          	jalr	1352(ra) # 800009e0 <uvmdealloc>
    800014a0:	85aa                	mv	a1,a0
    800014a2:	b7e1                	j	8000146a <growproc+0x22>

00000000800014a4 <fork>:
{
    800014a4:	7139                	addi	sp,sp,-64
    800014a6:	fc06                	sd	ra,56(sp)
    800014a8:	f822                	sd	s0,48(sp)
    800014aa:	f426                	sd	s1,40(sp)
    800014ac:	f04a                	sd	s2,32(sp)
    800014ae:	ec4e                	sd	s3,24(sp)
    800014b0:	e852                	sd	s4,16(sp)
    800014b2:	e456                	sd	s5,8(sp)
    800014b4:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    800014b6:	00000097          	auipc	ra,0x0
    800014ba:	c34080e7          	jalr	-972(ra) # 800010ea <myproc>
    800014be:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    800014c0:	00000097          	auipc	ra,0x0
    800014c4:	e38080e7          	jalr	-456(ra) # 800012f8 <allocproc>
    800014c8:	10050c63          	beqz	a0,800015e0 <fork+0x13c>
    800014cc:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800014ce:	048ab603          	ld	a2,72(s5)
    800014d2:	692c                	ld	a1,80(a0)
    800014d4:	050ab503          	ld	a0,80(s5)
    800014d8:	fffff097          	auipc	ra,0xfffff
    800014dc:	6a4080e7          	jalr	1700(ra) # 80000b7c <uvmcopy>
    800014e0:	04054863          	bltz	a0,80001530 <fork+0x8c>
  np->sz = p->sz;
    800014e4:	048ab783          	ld	a5,72(s5)
    800014e8:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    800014ec:	058ab683          	ld	a3,88(s5)
    800014f0:	87b6                	mv	a5,a3
    800014f2:	058a3703          	ld	a4,88(s4)
    800014f6:	12068693          	addi	a3,a3,288
    800014fa:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    800014fe:	6788                	ld	a0,8(a5)
    80001500:	6b8c                	ld	a1,16(a5)
    80001502:	6f90                	ld	a2,24(a5)
    80001504:	01073023          	sd	a6,0(a4)
    80001508:	e708                	sd	a0,8(a4)
    8000150a:	eb0c                	sd	a1,16(a4)
    8000150c:	ef10                	sd	a2,24(a4)
    8000150e:	02078793          	addi	a5,a5,32
    80001512:	02070713          	addi	a4,a4,32
    80001516:	fed792e3          	bne	a5,a3,800014fa <fork+0x56>
  np->trapframe->a0 = 0;
    8000151a:	058a3783          	ld	a5,88(s4)
    8000151e:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001522:	0d0a8493          	addi	s1,s5,208
    80001526:	0d0a0913          	addi	s2,s4,208
    8000152a:	150a8993          	addi	s3,s5,336
    8000152e:	a00d                	j	80001550 <fork+0xac>
    freeproc(np);
    80001530:	8552                	mv	a0,s4
    80001532:	00000097          	auipc	ra,0x0
    80001536:	d6e080e7          	jalr	-658(ra) # 800012a0 <freeproc>
    release(&np->lock);
    8000153a:	8552                	mv	a0,s4
    8000153c:	00005097          	auipc	ra,0x5
    80001540:	f32080e7          	jalr	-206(ra) # 8000646e <release>
    return -1;
    80001544:	597d                	li	s2,-1
    80001546:	a059                	j	800015cc <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001548:	04a1                	addi	s1,s1,8
    8000154a:	0921                	addi	s2,s2,8
    8000154c:	01348b63          	beq	s1,s3,80001562 <fork+0xbe>
    if(p->ofile[i])
    80001550:	6088                	ld	a0,0(s1)
    80001552:	d97d                	beqz	a0,80001548 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001554:	00002097          	auipc	ra,0x2
    80001558:	6b8080e7          	jalr	1720(ra) # 80003c0c <filedup>
    8000155c:	00a93023          	sd	a0,0(s2)
    80001560:	b7e5                	j	80001548 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001562:	150ab503          	ld	a0,336(s5)
    80001566:	00002097          	auipc	ra,0x2
    8000156a:	82c080e7          	jalr	-2004(ra) # 80002d92 <idup>
    8000156e:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001572:	4641                	li	a2,16
    80001574:	158a8593          	addi	a1,s5,344
    80001578:	158a0513          	addi	a0,s4,344
    8000157c:	fffff097          	auipc	ra,0xfffff
    80001580:	e94080e7          	jalr	-364(ra) # 80000410 <safestrcpy>
  pid = np->pid;
    80001584:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001588:	8552                	mv	a0,s4
    8000158a:	00005097          	auipc	ra,0x5
    8000158e:	ee4080e7          	jalr	-284(ra) # 8000646e <release>
  acquire(&wait_lock);
    80001592:	00107497          	auipc	s1,0x107
    80001596:	51648493          	addi	s1,s1,1302 # 80108aa8 <wait_lock>
    8000159a:	8526                	mv	a0,s1
    8000159c:	00005097          	auipc	ra,0x5
    800015a0:	e1e080e7          	jalr	-482(ra) # 800063ba <acquire>
  np->parent = p;
    800015a4:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    800015a8:	8526                	mv	a0,s1
    800015aa:	00005097          	auipc	ra,0x5
    800015ae:	ec4080e7          	jalr	-316(ra) # 8000646e <release>
  acquire(&np->lock);
    800015b2:	8552                	mv	a0,s4
    800015b4:	00005097          	auipc	ra,0x5
    800015b8:	e06080e7          	jalr	-506(ra) # 800063ba <acquire>
  np->state = RUNNABLE;
    800015bc:	478d                	li	a5,3
    800015be:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    800015c2:	8552                	mv	a0,s4
    800015c4:	00005097          	auipc	ra,0x5
    800015c8:	eaa080e7          	jalr	-342(ra) # 8000646e <release>
}
    800015cc:	854a                	mv	a0,s2
    800015ce:	70e2                	ld	ra,56(sp)
    800015d0:	7442                	ld	s0,48(sp)
    800015d2:	74a2                	ld	s1,40(sp)
    800015d4:	7902                	ld	s2,32(sp)
    800015d6:	69e2                	ld	s3,24(sp)
    800015d8:	6a42                	ld	s4,16(sp)
    800015da:	6aa2                	ld	s5,8(sp)
    800015dc:	6121                	addi	sp,sp,64
    800015de:	8082                	ret
    return -1;
    800015e0:	597d                	li	s2,-1
    800015e2:	b7ed                	j	800015cc <fork+0x128>

00000000800015e4 <scheduler>:
{
    800015e4:	7139                	addi	sp,sp,-64
    800015e6:	fc06                	sd	ra,56(sp)
    800015e8:	f822                	sd	s0,48(sp)
    800015ea:	f426                	sd	s1,40(sp)
    800015ec:	f04a                	sd	s2,32(sp)
    800015ee:	ec4e                	sd	s3,24(sp)
    800015f0:	e852                	sd	s4,16(sp)
    800015f2:	e456                	sd	s5,8(sp)
    800015f4:	e05a                	sd	s6,0(sp)
    800015f6:	0080                	addi	s0,sp,64
    800015f8:	8792                	mv	a5,tp
  int id = r_tp();
    800015fa:	2781                	sext.w	a5,a5
  c->proc = 0;
    800015fc:	00779a93          	slli	s5,a5,0x7
    80001600:	00107717          	auipc	a4,0x107
    80001604:	49070713          	addi	a4,a4,1168 # 80108a90 <pid_lock>
    80001608:	9756                	add	a4,a4,s5
    8000160a:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    8000160e:	00107717          	auipc	a4,0x107
    80001612:	4ba70713          	addi	a4,a4,1210 # 80108ac8 <cpus+0x8>
    80001616:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001618:	498d                	li	s3,3
        p->state = RUNNING;
    8000161a:	4b11                	li	s6,4
        c->proc = p;
    8000161c:	079e                	slli	a5,a5,0x7
    8000161e:	00107a17          	auipc	s4,0x107
    80001622:	472a0a13          	addi	s4,s4,1138 # 80108a90 <pid_lock>
    80001626:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001628:	0010d917          	auipc	s2,0x10d
    8000162c:	29890913          	addi	s2,s2,664 # 8010e8c0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001630:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001634:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001638:	10079073          	csrw	sstatus,a5
    8000163c:	00108497          	auipc	s1,0x108
    80001640:	88448493          	addi	s1,s1,-1916 # 80108ec0 <proc>
    80001644:	a811                	j	80001658 <scheduler+0x74>
      release(&p->lock);
    80001646:	8526                	mv	a0,s1
    80001648:	00005097          	auipc	ra,0x5
    8000164c:	e26080e7          	jalr	-474(ra) # 8000646e <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001650:	16848493          	addi	s1,s1,360
    80001654:	fd248ee3          	beq	s1,s2,80001630 <scheduler+0x4c>
      acquire(&p->lock);
    80001658:	8526                	mv	a0,s1
    8000165a:	00005097          	auipc	ra,0x5
    8000165e:	d60080e7          	jalr	-672(ra) # 800063ba <acquire>
      if(p->state == RUNNABLE) {
    80001662:	4c9c                	lw	a5,24(s1)
    80001664:	ff3791e3          	bne	a5,s3,80001646 <scheduler+0x62>
        p->state = RUNNING;
    80001668:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    8000166c:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001670:	06048593          	addi	a1,s1,96
    80001674:	8556                	mv	a0,s5
    80001676:	00000097          	auipc	ra,0x0
    8000167a:	682080e7          	jalr	1666(ra) # 80001cf8 <swtch>
        c->proc = 0;
    8000167e:	020a3823          	sd	zero,48(s4)
    80001682:	b7d1                	j	80001646 <scheduler+0x62>

0000000080001684 <sched>:
{
    80001684:	7179                	addi	sp,sp,-48
    80001686:	f406                	sd	ra,40(sp)
    80001688:	f022                	sd	s0,32(sp)
    8000168a:	ec26                	sd	s1,24(sp)
    8000168c:	e84a                	sd	s2,16(sp)
    8000168e:	e44e                	sd	s3,8(sp)
    80001690:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001692:	00000097          	auipc	ra,0x0
    80001696:	a58080e7          	jalr	-1448(ra) # 800010ea <myproc>
    8000169a:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000169c:	00005097          	auipc	ra,0x5
    800016a0:	ca4080e7          	jalr	-860(ra) # 80006340 <holding>
    800016a4:	c93d                	beqz	a0,8000171a <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800016a6:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800016a8:	2781                	sext.w	a5,a5
    800016aa:	079e                	slli	a5,a5,0x7
    800016ac:	00107717          	auipc	a4,0x107
    800016b0:	3e470713          	addi	a4,a4,996 # 80108a90 <pid_lock>
    800016b4:	97ba                	add	a5,a5,a4
    800016b6:	0a87a703          	lw	a4,168(a5)
    800016ba:	4785                	li	a5,1
    800016bc:	06f71763          	bne	a4,a5,8000172a <sched+0xa6>
  if(p->state == RUNNING)
    800016c0:	4c98                	lw	a4,24(s1)
    800016c2:	4791                	li	a5,4
    800016c4:	06f70b63          	beq	a4,a5,8000173a <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800016c8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800016cc:	8b89                	andi	a5,a5,2
  if(intr_get())
    800016ce:	efb5                	bnez	a5,8000174a <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800016d0:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800016d2:	00107917          	auipc	s2,0x107
    800016d6:	3be90913          	addi	s2,s2,958 # 80108a90 <pid_lock>
    800016da:	2781                	sext.w	a5,a5
    800016dc:	079e                	slli	a5,a5,0x7
    800016de:	97ca                	add	a5,a5,s2
    800016e0:	0ac7a983          	lw	s3,172(a5)
    800016e4:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800016e6:	2781                	sext.w	a5,a5
    800016e8:	079e                	slli	a5,a5,0x7
    800016ea:	00107597          	auipc	a1,0x107
    800016ee:	3de58593          	addi	a1,a1,990 # 80108ac8 <cpus+0x8>
    800016f2:	95be                	add	a1,a1,a5
    800016f4:	06048513          	addi	a0,s1,96
    800016f8:	00000097          	auipc	ra,0x0
    800016fc:	600080e7          	jalr	1536(ra) # 80001cf8 <swtch>
    80001700:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001702:	2781                	sext.w	a5,a5
    80001704:	079e                	slli	a5,a5,0x7
    80001706:	97ca                	add	a5,a5,s2
    80001708:	0b37a623          	sw	s3,172(a5)
}
    8000170c:	70a2                	ld	ra,40(sp)
    8000170e:	7402                	ld	s0,32(sp)
    80001710:	64e2                	ld	s1,24(sp)
    80001712:	6942                	ld	s2,16(sp)
    80001714:	69a2                	ld	s3,8(sp)
    80001716:	6145                	addi	sp,sp,48
    80001718:	8082                	ret
    panic("sched p->lock");
    8000171a:	00007517          	auipc	a0,0x7
    8000171e:	ae650513          	addi	a0,a0,-1306 # 80008200 <etext+0x200>
    80001722:	00004097          	auipc	ra,0x4
    80001726:	75c080e7          	jalr	1884(ra) # 80005e7e <panic>
    panic("sched locks");
    8000172a:	00007517          	auipc	a0,0x7
    8000172e:	ae650513          	addi	a0,a0,-1306 # 80008210 <etext+0x210>
    80001732:	00004097          	auipc	ra,0x4
    80001736:	74c080e7          	jalr	1868(ra) # 80005e7e <panic>
    panic("sched running");
    8000173a:	00007517          	auipc	a0,0x7
    8000173e:	ae650513          	addi	a0,a0,-1306 # 80008220 <etext+0x220>
    80001742:	00004097          	auipc	ra,0x4
    80001746:	73c080e7          	jalr	1852(ra) # 80005e7e <panic>
    panic("sched interruptible");
    8000174a:	00007517          	auipc	a0,0x7
    8000174e:	ae650513          	addi	a0,a0,-1306 # 80008230 <etext+0x230>
    80001752:	00004097          	auipc	ra,0x4
    80001756:	72c080e7          	jalr	1836(ra) # 80005e7e <panic>

000000008000175a <yield>:
{
    8000175a:	1101                	addi	sp,sp,-32
    8000175c:	ec06                	sd	ra,24(sp)
    8000175e:	e822                	sd	s0,16(sp)
    80001760:	e426                	sd	s1,8(sp)
    80001762:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001764:	00000097          	auipc	ra,0x0
    80001768:	986080e7          	jalr	-1658(ra) # 800010ea <myproc>
    8000176c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000176e:	00005097          	auipc	ra,0x5
    80001772:	c4c080e7          	jalr	-948(ra) # 800063ba <acquire>
  p->state = RUNNABLE;
    80001776:	478d                	li	a5,3
    80001778:	cc9c                	sw	a5,24(s1)
  sched();
    8000177a:	00000097          	auipc	ra,0x0
    8000177e:	f0a080e7          	jalr	-246(ra) # 80001684 <sched>
  release(&p->lock);
    80001782:	8526                	mv	a0,s1
    80001784:	00005097          	auipc	ra,0x5
    80001788:	cea080e7          	jalr	-790(ra) # 8000646e <release>
}
    8000178c:	60e2                	ld	ra,24(sp)
    8000178e:	6442                	ld	s0,16(sp)
    80001790:	64a2                	ld	s1,8(sp)
    80001792:	6105                	addi	sp,sp,32
    80001794:	8082                	ret

0000000080001796 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001796:	7179                	addi	sp,sp,-48
    80001798:	f406                	sd	ra,40(sp)
    8000179a:	f022                	sd	s0,32(sp)
    8000179c:	ec26                	sd	s1,24(sp)
    8000179e:	e84a                	sd	s2,16(sp)
    800017a0:	e44e                	sd	s3,8(sp)
    800017a2:	1800                	addi	s0,sp,48
    800017a4:	89aa                	mv	s3,a0
    800017a6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800017a8:	00000097          	auipc	ra,0x0
    800017ac:	942080e7          	jalr	-1726(ra) # 800010ea <myproc>
    800017b0:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800017b2:	00005097          	auipc	ra,0x5
    800017b6:	c08080e7          	jalr	-1016(ra) # 800063ba <acquire>
  release(lk);
    800017ba:	854a                	mv	a0,s2
    800017bc:	00005097          	auipc	ra,0x5
    800017c0:	cb2080e7          	jalr	-846(ra) # 8000646e <release>

  // Go to sleep.
  p->chan = chan;
    800017c4:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800017c8:	4789                	li	a5,2
    800017ca:	cc9c                	sw	a5,24(s1)

  sched();
    800017cc:	00000097          	auipc	ra,0x0
    800017d0:	eb8080e7          	jalr	-328(ra) # 80001684 <sched>

  // Tidy up.
  p->chan = 0;
    800017d4:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800017d8:	8526                	mv	a0,s1
    800017da:	00005097          	auipc	ra,0x5
    800017de:	c94080e7          	jalr	-876(ra) # 8000646e <release>
  acquire(lk);
    800017e2:	854a                	mv	a0,s2
    800017e4:	00005097          	auipc	ra,0x5
    800017e8:	bd6080e7          	jalr	-1066(ra) # 800063ba <acquire>
}
    800017ec:	70a2                	ld	ra,40(sp)
    800017ee:	7402                	ld	s0,32(sp)
    800017f0:	64e2                	ld	s1,24(sp)
    800017f2:	6942                	ld	s2,16(sp)
    800017f4:	69a2                	ld	s3,8(sp)
    800017f6:	6145                	addi	sp,sp,48
    800017f8:	8082                	ret

00000000800017fa <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800017fa:	7139                	addi	sp,sp,-64
    800017fc:	fc06                	sd	ra,56(sp)
    800017fe:	f822                	sd	s0,48(sp)
    80001800:	f426                	sd	s1,40(sp)
    80001802:	f04a                	sd	s2,32(sp)
    80001804:	ec4e                	sd	s3,24(sp)
    80001806:	e852                	sd	s4,16(sp)
    80001808:	e456                	sd	s5,8(sp)
    8000180a:	0080                	addi	s0,sp,64
    8000180c:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000180e:	00107497          	auipc	s1,0x107
    80001812:	6b248493          	addi	s1,s1,1714 # 80108ec0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001816:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001818:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000181a:	0010d917          	auipc	s2,0x10d
    8000181e:	0a690913          	addi	s2,s2,166 # 8010e8c0 <tickslock>
    80001822:	a811                	j	80001836 <wakeup+0x3c>
      }
      release(&p->lock);
    80001824:	8526                	mv	a0,s1
    80001826:	00005097          	auipc	ra,0x5
    8000182a:	c48080e7          	jalr	-952(ra) # 8000646e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000182e:	16848493          	addi	s1,s1,360
    80001832:	03248663          	beq	s1,s2,8000185e <wakeup+0x64>
    if(p != myproc()){
    80001836:	00000097          	auipc	ra,0x0
    8000183a:	8b4080e7          	jalr	-1868(ra) # 800010ea <myproc>
    8000183e:	fea488e3          	beq	s1,a0,8000182e <wakeup+0x34>
      acquire(&p->lock);
    80001842:	8526                	mv	a0,s1
    80001844:	00005097          	auipc	ra,0x5
    80001848:	b76080e7          	jalr	-1162(ra) # 800063ba <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000184c:	4c9c                	lw	a5,24(s1)
    8000184e:	fd379be3          	bne	a5,s3,80001824 <wakeup+0x2a>
    80001852:	709c                	ld	a5,32(s1)
    80001854:	fd4798e3          	bne	a5,s4,80001824 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001858:	0154ac23          	sw	s5,24(s1)
    8000185c:	b7e1                	j	80001824 <wakeup+0x2a>
    }
  }
}
    8000185e:	70e2                	ld	ra,56(sp)
    80001860:	7442                	ld	s0,48(sp)
    80001862:	74a2                	ld	s1,40(sp)
    80001864:	7902                	ld	s2,32(sp)
    80001866:	69e2                	ld	s3,24(sp)
    80001868:	6a42                	ld	s4,16(sp)
    8000186a:	6aa2                	ld	s5,8(sp)
    8000186c:	6121                	addi	sp,sp,64
    8000186e:	8082                	ret

0000000080001870 <reparent>:
{
    80001870:	7179                	addi	sp,sp,-48
    80001872:	f406                	sd	ra,40(sp)
    80001874:	f022                	sd	s0,32(sp)
    80001876:	ec26                	sd	s1,24(sp)
    80001878:	e84a                	sd	s2,16(sp)
    8000187a:	e44e                	sd	s3,8(sp)
    8000187c:	e052                	sd	s4,0(sp)
    8000187e:	1800                	addi	s0,sp,48
    80001880:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001882:	00107497          	auipc	s1,0x107
    80001886:	63e48493          	addi	s1,s1,1598 # 80108ec0 <proc>
      pp->parent = initproc;
    8000188a:	00007a17          	auipc	s4,0x7
    8000188e:	086a0a13          	addi	s4,s4,134 # 80008910 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001892:	0010d997          	auipc	s3,0x10d
    80001896:	02e98993          	addi	s3,s3,46 # 8010e8c0 <tickslock>
    8000189a:	a029                	j	800018a4 <reparent+0x34>
    8000189c:	16848493          	addi	s1,s1,360
    800018a0:	01348d63          	beq	s1,s3,800018ba <reparent+0x4a>
    if(pp->parent == p){
    800018a4:	7c9c                	ld	a5,56(s1)
    800018a6:	ff279be3          	bne	a5,s2,8000189c <reparent+0x2c>
      pp->parent = initproc;
    800018aa:	000a3503          	ld	a0,0(s4)
    800018ae:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800018b0:	00000097          	auipc	ra,0x0
    800018b4:	f4a080e7          	jalr	-182(ra) # 800017fa <wakeup>
    800018b8:	b7d5                	j	8000189c <reparent+0x2c>
}
    800018ba:	70a2                	ld	ra,40(sp)
    800018bc:	7402                	ld	s0,32(sp)
    800018be:	64e2                	ld	s1,24(sp)
    800018c0:	6942                	ld	s2,16(sp)
    800018c2:	69a2                	ld	s3,8(sp)
    800018c4:	6a02                	ld	s4,0(sp)
    800018c6:	6145                	addi	sp,sp,48
    800018c8:	8082                	ret

00000000800018ca <exit>:
{
    800018ca:	7179                	addi	sp,sp,-48
    800018cc:	f406                	sd	ra,40(sp)
    800018ce:	f022                	sd	s0,32(sp)
    800018d0:	ec26                	sd	s1,24(sp)
    800018d2:	e84a                	sd	s2,16(sp)
    800018d4:	e44e                	sd	s3,8(sp)
    800018d6:	e052                	sd	s4,0(sp)
    800018d8:	1800                	addi	s0,sp,48
    800018da:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800018dc:	00000097          	auipc	ra,0x0
    800018e0:	80e080e7          	jalr	-2034(ra) # 800010ea <myproc>
    800018e4:	89aa                	mv	s3,a0
  if(p == initproc)
    800018e6:	00007797          	auipc	a5,0x7
    800018ea:	02a7b783          	ld	a5,42(a5) # 80008910 <initproc>
    800018ee:	0d050493          	addi	s1,a0,208
    800018f2:	15050913          	addi	s2,a0,336
    800018f6:	02a79363          	bne	a5,a0,8000191c <exit+0x52>
    panic("init exiting");
    800018fa:	00007517          	auipc	a0,0x7
    800018fe:	94e50513          	addi	a0,a0,-1714 # 80008248 <etext+0x248>
    80001902:	00004097          	auipc	ra,0x4
    80001906:	57c080e7          	jalr	1404(ra) # 80005e7e <panic>
      fileclose(f);
    8000190a:	00002097          	auipc	ra,0x2
    8000190e:	354080e7          	jalr	852(ra) # 80003c5e <fileclose>
      p->ofile[fd] = 0;
    80001912:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001916:	04a1                	addi	s1,s1,8
    80001918:	01248563          	beq	s1,s2,80001922 <exit+0x58>
    if(p->ofile[fd]){
    8000191c:	6088                	ld	a0,0(s1)
    8000191e:	f575                	bnez	a0,8000190a <exit+0x40>
    80001920:	bfdd                	j	80001916 <exit+0x4c>
  begin_op();
    80001922:	00002097          	auipc	ra,0x2
    80001926:	e70080e7          	jalr	-400(ra) # 80003792 <begin_op>
  iput(p->cwd);
    8000192a:	1509b503          	ld	a0,336(s3)
    8000192e:	00001097          	auipc	ra,0x1
    80001932:	65c080e7          	jalr	1628(ra) # 80002f8a <iput>
  end_op();
    80001936:	00002097          	auipc	ra,0x2
    8000193a:	edc080e7          	jalr	-292(ra) # 80003812 <end_op>
  p->cwd = 0;
    8000193e:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80001942:	00107497          	auipc	s1,0x107
    80001946:	16648493          	addi	s1,s1,358 # 80108aa8 <wait_lock>
    8000194a:	8526                	mv	a0,s1
    8000194c:	00005097          	auipc	ra,0x5
    80001950:	a6e080e7          	jalr	-1426(ra) # 800063ba <acquire>
  reparent(p);
    80001954:	854e                	mv	a0,s3
    80001956:	00000097          	auipc	ra,0x0
    8000195a:	f1a080e7          	jalr	-230(ra) # 80001870 <reparent>
  wakeup(p->parent);
    8000195e:	0389b503          	ld	a0,56(s3)
    80001962:	00000097          	auipc	ra,0x0
    80001966:	e98080e7          	jalr	-360(ra) # 800017fa <wakeup>
  acquire(&p->lock);
    8000196a:	854e                	mv	a0,s3
    8000196c:	00005097          	auipc	ra,0x5
    80001970:	a4e080e7          	jalr	-1458(ra) # 800063ba <acquire>
  p->xstate = status;
    80001974:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80001978:	4795                	li	a5,5
    8000197a:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000197e:	8526                	mv	a0,s1
    80001980:	00005097          	auipc	ra,0x5
    80001984:	aee080e7          	jalr	-1298(ra) # 8000646e <release>
  sched();
    80001988:	00000097          	auipc	ra,0x0
    8000198c:	cfc080e7          	jalr	-772(ra) # 80001684 <sched>
  panic("zombie exit");
    80001990:	00007517          	auipc	a0,0x7
    80001994:	8c850513          	addi	a0,a0,-1848 # 80008258 <etext+0x258>
    80001998:	00004097          	auipc	ra,0x4
    8000199c:	4e6080e7          	jalr	1254(ra) # 80005e7e <panic>

00000000800019a0 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800019a0:	7179                	addi	sp,sp,-48
    800019a2:	f406                	sd	ra,40(sp)
    800019a4:	f022                	sd	s0,32(sp)
    800019a6:	ec26                	sd	s1,24(sp)
    800019a8:	e84a                	sd	s2,16(sp)
    800019aa:	e44e                	sd	s3,8(sp)
    800019ac:	1800                	addi	s0,sp,48
    800019ae:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800019b0:	00107497          	auipc	s1,0x107
    800019b4:	51048493          	addi	s1,s1,1296 # 80108ec0 <proc>
    800019b8:	0010d997          	auipc	s3,0x10d
    800019bc:	f0898993          	addi	s3,s3,-248 # 8010e8c0 <tickslock>
    acquire(&p->lock);
    800019c0:	8526                	mv	a0,s1
    800019c2:	00005097          	auipc	ra,0x5
    800019c6:	9f8080e7          	jalr	-1544(ra) # 800063ba <acquire>
    if(p->pid == pid){
    800019ca:	589c                	lw	a5,48(s1)
    800019cc:	01278d63          	beq	a5,s2,800019e6 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800019d0:	8526                	mv	a0,s1
    800019d2:	00005097          	auipc	ra,0x5
    800019d6:	a9c080e7          	jalr	-1380(ra) # 8000646e <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800019da:	16848493          	addi	s1,s1,360
    800019de:	ff3491e3          	bne	s1,s3,800019c0 <kill+0x20>
  }
  return -1;
    800019e2:	557d                	li	a0,-1
    800019e4:	a829                	j	800019fe <kill+0x5e>
      p->killed = 1;
    800019e6:	4785                	li	a5,1
    800019e8:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800019ea:	4c98                	lw	a4,24(s1)
    800019ec:	4789                	li	a5,2
    800019ee:	00f70f63          	beq	a4,a5,80001a0c <kill+0x6c>
      release(&p->lock);
    800019f2:	8526                	mv	a0,s1
    800019f4:	00005097          	auipc	ra,0x5
    800019f8:	a7a080e7          	jalr	-1414(ra) # 8000646e <release>
      return 0;
    800019fc:	4501                	li	a0,0
}
    800019fe:	70a2                	ld	ra,40(sp)
    80001a00:	7402                	ld	s0,32(sp)
    80001a02:	64e2                	ld	s1,24(sp)
    80001a04:	6942                	ld	s2,16(sp)
    80001a06:	69a2                	ld	s3,8(sp)
    80001a08:	6145                	addi	sp,sp,48
    80001a0a:	8082                	ret
        p->state = RUNNABLE;
    80001a0c:	478d                	li	a5,3
    80001a0e:	cc9c                	sw	a5,24(s1)
    80001a10:	b7cd                	j	800019f2 <kill+0x52>

0000000080001a12 <setkilled>:

void
setkilled(struct proc *p)
{
    80001a12:	1101                	addi	sp,sp,-32
    80001a14:	ec06                	sd	ra,24(sp)
    80001a16:	e822                	sd	s0,16(sp)
    80001a18:	e426                	sd	s1,8(sp)
    80001a1a:	1000                	addi	s0,sp,32
    80001a1c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001a1e:	00005097          	auipc	ra,0x5
    80001a22:	99c080e7          	jalr	-1636(ra) # 800063ba <acquire>
  p->killed = 1;
    80001a26:	4785                	li	a5,1
    80001a28:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80001a2a:	8526                	mv	a0,s1
    80001a2c:	00005097          	auipc	ra,0x5
    80001a30:	a42080e7          	jalr	-1470(ra) # 8000646e <release>
}
    80001a34:	60e2                	ld	ra,24(sp)
    80001a36:	6442                	ld	s0,16(sp)
    80001a38:	64a2                	ld	s1,8(sp)
    80001a3a:	6105                	addi	sp,sp,32
    80001a3c:	8082                	ret

0000000080001a3e <killed>:

int
killed(struct proc *p)
{
    80001a3e:	1101                	addi	sp,sp,-32
    80001a40:	ec06                	sd	ra,24(sp)
    80001a42:	e822                	sd	s0,16(sp)
    80001a44:	e426                	sd	s1,8(sp)
    80001a46:	e04a                	sd	s2,0(sp)
    80001a48:	1000                	addi	s0,sp,32
    80001a4a:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80001a4c:	00005097          	auipc	ra,0x5
    80001a50:	96e080e7          	jalr	-1682(ra) # 800063ba <acquire>
  k = p->killed;
    80001a54:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80001a58:	8526                	mv	a0,s1
    80001a5a:	00005097          	auipc	ra,0x5
    80001a5e:	a14080e7          	jalr	-1516(ra) # 8000646e <release>
  return k;
}
    80001a62:	854a                	mv	a0,s2
    80001a64:	60e2                	ld	ra,24(sp)
    80001a66:	6442                	ld	s0,16(sp)
    80001a68:	64a2                	ld	s1,8(sp)
    80001a6a:	6902                	ld	s2,0(sp)
    80001a6c:	6105                	addi	sp,sp,32
    80001a6e:	8082                	ret

0000000080001a70 <wait>:
{
    80001a70:	715d                	addi	sp,sp,-80
    80001a72:	e486                	sd	ra,72(sp)
    80001a74:	e0a2                	sd	s0,64(sp)
    80001a76:	fc26                	sd	s1,56(sp)
    80001a78:	f84a                	sd	s2,48(sp)
    80001a7a:	f44e                	sd	s3,40(sp)
    80001a7c:	f052                	sd	s4,32(sp)
    80001a7e:	ec56                	sd	s5,24(sp)
    80001a80:	e85a                	sd	s6,16(sp)
    80001a82:	e45e                	sd	s7,8(sp)
    80001a84:	e062                	sd	s8,0(sp)
    80001a86:	0880                	addi	s0,sp,80
    80001a88:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80001a8a:	fffff097          	auipc	ra,0xfffff
    80001a8e:	660080e7          	jalr	1632(ra) # 800010ea <myproc>
    80001a92:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80001a94:	00107517          	auipc	a0,0x107
    80001a98:	01450513          	addi	a0,a0,20 # 80108aa8 <wait_lock>
    80001a9c:	00005097          	auipc	ra,0x5
    80001aa0:	91e080e7          	jalr	-1762(ra) # 800063ba <acquire>
    havekids = 0;
    80001aa4:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80001aa6:	4a15                	li	s4,5
        havekids = 1;
    80001aa8:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001aaa:	0010d997          	auipc	s3,0x10d
    80001aae:	e1698993          	addi	s3,s3,-490 # 8010e8c0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001ab2:	00107c17          	auipc	s8,0x107
    80001ab6:	ff6c0c13          	addi	s8,s8,-10 # 80108aa8 <wait_lock>
    havekids = 0;
    80001aba:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001abc:	00107497          	auipc	s1,0x107
    80001ac0:	40448493          	addi	s1,s1,1028 # 80108ec0 <proc>
    80001ac4:	a0bd                	j	80001b32 <wait+0xc2>
          pid = pp->pid;
    80001ac6:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80001aca:	000b0e63          	beqz	s6,80001ae6 <wait+0x76>
    80001ace:	4691                	li	a3,4
    80001ad0:	02c48613          	addi	a2,s1,44
    80001ad4:	85da                	mv	a1,s6
    80001ad6:	05093503          	ld	a0,80(s2)
    80001ada:	fffff097          	auipc	ra,0xfffff
    80001ade:	3a0080e7          	jalr	928(ra) # 80000e7a <copyout>
    80001ae2:	02054563          	bltz	a0,80001b0c <wait+0x9c>
          freeproc(pp);
    80001ae6:	8526                	mv	a0,s1
    80001ae8:	fffff097          	auipc	ra,0xfffff
    80001aec:	7b8080e7          	jalr	1976(ra) # 800012a0 <freeproc>
          release(&pp->lock);
    80001af0:	8526                	mv	a0,s1
    80001af2:	00005097          	auipc	ra,0x5
    80001af6:	97c080e7          	jalr	-1668(ra) # 8000646e <release>
          release(&wait_lock);
    80001afa:	00107517          	auipc	a0,0x107
    80001afe:	fae50513          	addi	a0,a0,-82 # 80108aa8 <wait_lock>
    80001b02:	00005097          	auipc	ra,0x5
    80001b06:	96c080e7          	jalr	-1684(ra) # 8000646e <release>
          return pid;
    80001b0a:	a0b5                	j	80001b76 <wait+0x106>
            release(&pp->lock);
    80001b0c:	8526                	mv	a0,s1
    80001b0e:	00005097          	auipc	ra,0x5
    80001b12:	960080e7          	jalr	-1696(ra) # 8000646e <release>
            release(&wait_lock);
    80001b16:	00107517          	auipc	a0,0x107
    80001b1a:	f9250513          	addi	a0,a0,-110 # 80108aa8 <wait_lock>
    80001b1e:	00005097          	auipc	ra,0x5
    80001b22:	950080e7          	jalr	-1712(ra) # 8000646e <release>
            return -1;
    80001b26:	59fd                	li	s3,-1
    80001b28:	a0b9                	j	80001b76 <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001b2a:	16848493          	addi	s1,s1,360
    80001b2e:	03348463          	beq	s1,s3,80001b56 <wait+0xe6>
      if(pp->parent == p){
    80001b32:	7c9c                	ld	a5,56(s1)
    80001b34:	ff279be3          	bne	a5,s2,80001b2a <wait+0xba>
        acquire(&pp->lock);
    80001b38:	8526                	mv	a0,s1
    80001b3a:	00005097          	auipc	ra,0x5
    80001b3e:	880080e7          	jalr	-1920(ra) # 800063ba <acquire>
        if(pp->state == ZOMBIE){
    80001b42:	4c9c                	lw	a5,24(s1)
    80001b44:	f94781e3          	beq	a5,s4,80001ac6 <wait+0x56>
        release(&pp->lock);
    80001b48:	8526                	mv	a0,s1
    80001b4a:	00005097          	auipc	ra,0x5
    80001b4e:	924080e7          	jalr	-1756(ra) # 8000646e <release>
        havekids = 1;
    80001b52:	8756                	mv	a4,s5
    80001b54:	bfd9                	j	80001b2a <wait+0xba>
    if(!havekids || killed(p)){
    80001b56:	c719                	beqz	a4,80001b64 <wait+0xf4>
    80001b58:	854a                	mv	a0,s2
    80001b5a:	00000097          	auipc	ra,0x0
    80001b5e:	ee4080e7          	jalr	-284(ra) # 80001a3e <killed>
    80001b62:	c51d                	beqz	a0,80001b90 <wait+0x120>
      release(&wait_lock);
    80001b64:	00107517          	auipc	a0,0x107
    80001b68:	f4450513          	addi	a0,a0,-188 # 80108aa8 <wait_lock>
    80001b6c:	00005097          	auipc	ra,0x5
    80001b70:	902080e7          	jalr	-1790(ra) # 8000646e <release>
      return -1;
    80001b74:	59fd                	li	s3,-1
}
    80001b76:	854e                	mv	a0,s3
    80001b78:	60a6                	ld	ra,72(sp)
    80001b7a:	6406                	ld	s0,64(sp)
    80001b7c:	74e2                	ld	s1,56(sp)
    80001b7e:	7942                	ld	s2,48(sp)
    80001b80:	79a2                	ld	s3,40(sp)
    80001b82:	7a02                	ld	s4,32(sp)
    80001b84:	6ae2                	ld	s5,24(sp)
    80001b86:	6b42                	ld	s6,16(sp)
    80001b88:	6ba2                	ld	s7,8(sp)
    80001b8a:	6c02                	ld	s8,0(sp)
    80001b8c:	6161                	addi	sp,sp,80
    80001b8e:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001b90:	85e2                	mv	a1,s8
    80001b92:	854a                	mv	a0,s2
    80001b94:	00000097          	auipc	ra,0x0
    80001b98:	c02080e7          	jalr	-1022(ra) # 80001796 <sleep>
    havekids = 0;
    80001b9c:	bf39                	j	80001aba <wait+0x4a>

0000000080001b9e <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80001b9e:	7179                	addi	sp,sp,-48
    80001ba0:	f406                	sd	ra,40(sp)
    80001ba2:	f022                	sd	s0,32(sp)
    80001ba4:	ec26                	sd	s1,24(sp)
    80001ba6:	e84a                	sd	s2,16(sp)
    80001ba8:	e44e                	sd	s3,8(sp)
    80001baa:	e052                	sd	s4,0(sp)
    80001bac:	1800                	addi	s0,sp,48
    80001bae:	84aa                	mv	s1,a0
    80001bb0:	892e                	mv	s2,a1
    80001bb2:	89b2                	mv	s3,a2
    80001bb4:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001bb6:	fffff097          	auipc	ra,0xfffff
    80001bba:	534080e7          	jalr	1332(ra) # 800010ea <myproc>
  if(user_dst){
    80001bbe:	c08d                	beqz	s1,80001be0 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80001bc0:	86d2                	mv	a3,s4
    80001bc2:	864e                	mv	a2,s3
    80001bc4:	85ca                	mv	a1,s2
    80001bc6:	6928                	ld	a0,80(a0)
    80001bc8:	fffff097          	auipc	ra,0xfffff
    80001bcc:	2b2080e7          	jalr	690(ra) # 80000e7a <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80001bd0:	70a2                	ld	ra,40(sp)
    80001bd2:	7402                	ld	s0,32(sp)
    80001bd4:	64e2                	ld	s1,24(sp)
    80001bd6:	6942                	ld	s2,16(sp)
    80001bd8:	69a2                	ld	s3,8(sp)
    80001bda:	6a02                	ld	s4,0(sp)
    80001bdc:	6145                	addi	sp,sp,48
    80001bde:	8082                	ret
    memmove((char *)dst, src, len);
    80001be0:	000a061b          	sext.w	a2,s4
    80001be4:	85ce                	mv	a1,s3
    80001be6:	854a                	mv	a0,s2
    80001be8:	ffffe097          	auipc	ra,0xffffe
    80001bec:	73a080e7          	jalr	1850(ra) # 80000322 <memmove>
    return 0;
    80001bf0:	8526                	mv	a0,s1
    80001bf2:	bff9                	j	80001bd0 <either_copyout+0x32>

0000000080001bf4 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80001bf4:	7179                	addi	sp,sp,-48
    80001bf6:	f406                	sd	ra,40(sp)
    80001bf8:	f022                	sd	s0,32(sp)
    80001bfa:	ec26                	sd	s1,24(sp)
    80001bfc:	e84a                	sd	s2,16(sp)
    80001bfe:	e44e                	sd	s3,8(sp)
    80001c00:	e052                	sd	s4,0(sp)
    80001c02:	1800                	addi	s0,sp,48
    80001c04:	892a                	mv	s2,a0
    80001c06:	84ae                	mv	s1,a1
    80001c08:	89b2                	mv	s3,a2
    80001c0a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001c0c:	fffff097          	auipc	ra,0xfffff
    80001c10:	4de080e7          	jalr	1246(ra) # 800010ea <myproc>
  if(user_src){
    80001c14:	c08d                	beqz	s1,80001c36 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80001c16:	86d2                	mv	a3,s4
    80001c18:	864e                	mv	a2,s3
    80001c1a:	85ca                	mv	a1,s2
    80001c1c:	6928                	ld	a0,80(a0)
    80001c1e:	fffff097          	auipc	ra,0xfffff
    80001c22:	068080e7          	jalr	104(ra) # 80000c86 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80001c26:	70a2                	ld	ra,40(sp)
    80001c28:	7402                	ld	s0,32(sp)
    80001c2a:	64e2                	ld	s1,24(sp)
    80001c2c:	6942                	ld	s2,16(sp)
    80001c2e:	69a2                	ld	s3,8(sp)
    80001c30:	6a02                	ld	s4,0(sp)
    80001c32:	6145                	addi	sp,sp,48
    80001c34:	8082                	ret
    memmove(dst, (char*)src, len);
    80001c36:	000a061b          	sext.w	a2,s4
    80001c3a:	85ce                	mv	a1,s3
    80001c3c:	854a                	mv	a0,s2
    80001c3e:	ffffe097          	auipc	ra,0xffffe
    80001c42:	6e4080e7          	jalr	1764(ra) # 80000322 <memmove>
    return 0;
    80001c46:	8526                	mv	a0,s1
    80001c48:	bff9                	j	80001c26 <either_copyin+0x32>

0000000080001c4a <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80001c4a:	715d                	addi	sp,sp,-80
    80001c4c:	e486                	sd	ra,72(sp)
    80001c4e:	e0a2                	sd	s0,64(sp)
    80001c50:	fc26                	sd	s1,56(sp)
    80001c52:	f84a                	sd	s2,48(sp)
    80001c54:	f44e                	sd	s3,40(sp)
    80001c56:	f052                	sd	s4,32(sp)
    80001c58:	ec56                	sd	s5,24(sp)
    80001c5a:	e85a                	sd	s6,16(sp)
    80001c5c:	e45e                	sd	s7,8(sp)
    80001c5e:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80001c60:	00006517          	auipc	a0,0x6
    80001c64:	3f850513          	addi	a0,a0,1016 # 80008058 <etext+0x58>
    80001c68:	00004097          	auipc	ra,0x4
    80001c6c:	260080e7          	jalr	608(ra) # 80005ec8 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001c70:	00107497          	auipc	s1,0x107
    80001c74:	3a848493          	addi	s1,s1,936 # 80109018 <proc+0x158>
    80001c78:	0010d917          	auipc	s2,0x10d
    80001c7c:	da090913          	addi	s2,s2,-608 # 8010ea18 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001c80:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80001c82:	00006997          	auipc	s3,0x6
    80001c86:	5e698993          	addi	s3,s3,1510 # 80008268 <etext+0x268>
    printf("%d %s %s", p->pid, state, p->name);
    80001c8a:	00006a97          	auipc	s5,0x6
    80001c8e:	5e6a8a93          	addi	s5,s5,1510 # 80008270 <etext+0x270>
    printf("\n");
    80001c92:	00006a17          	auipc	s4,0x6
    80001c96:	3c6a0a13          	addi	s4,s4,966 # 80008058 <etext+0x58>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001c9a:	00006b97          	auipc	s7,0x6
    80001c9e:	616b8b93          	addi	s7,s7,1558 # 800082b0 <states.0>
    80001ca2:	a00d                	j	80001cc4 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80001ca4:	ed86a583          	lw	a1,-296(a3)
    80001ca8:	8556                	mv	a0,s5
    80001caa:	00004097          	auipc	ra,0x4
    80001cae:	21e080e7          	jalr	542(ra) # 80005ec8 <printf>
    printf("\n");
    80001cb2:	8552                	mv	a0,s4
    80001cb4:	00004097          	auipc	ra,0x4
    80001cb8:	214080e7          	jalr	532(ra) # 80005ec8 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001cbc:	16848493          	addi	s1,s1,360
    80001cc0:	03248163          	beq	s1,s2,80001ce2 <procdump+0x98>
    if(p->state == UNUSED)
    80001cc4:	86a6                	mv	a3,s1
    80001cc6:	ec04a783          	lw	a5,-320(s1)
    80001cca:	dbed                	beqz	a5,80001cbc <procdump+0x72>
      state = "???";
    80001ccc:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001cce:	fcfb6be3          	bltu	s6,a5,80001ca4 <procdump+0x5a>
    80001cd2:	1782                	slli	a5,a5,0x20
    80001cd4:	9381                	srli	a5,a5,0x20
    80001cd6:	078e                	slli	a5,a5,0x3
    80001cd8:	97de                	add	a5,a5,s7
    80001cda:	6390                	ld	a2,0(a5)
    80001cdc:	f661                	bnez	a2,80001ca4 <procdump+0x5a>
      state = "???";
    80001cde:	864e                	mv	a2,s3
    80001ce0:	b7d1                	j	80001ca4 <procdump+0x5a>
  }
}
    80001ce2:	60a6                	ld	ra,72(sp)
    80001ce4:	6406                	ld	s0,64(sp)
    80001ce6:	74e2                	ld	s1,56(sp)
    80001ce8:	7942                	ld	s2,48(sp)
    80001cea:	79a2                	ld	s3,40(sp)
    80001cec:	7a02                	ld	s4,32(sp)
    80001cee:	6ae2                	ld	s5,24(sp)
    80001cf0:	6b42                	ld	s6,16(sp)
    80001cf2:	6ba2                	ld	s7,8(sp)
    80001cf4:	6161                	addi	sp,sp,80
    80001cf6:	8082                	ret

0000000080001cf8 <swtch>:
    80001cf8:	00153023          	sd	ra,0(a0)
    80001cfc:	00253423          	sd	sp,8(a0)
    80001d00:	e900                	sd	s0,16(a0)
    80001d02:	ed04                	sd	s1,24(a0)
    80001d04:	03253023          	sd	s2,32(a0)
    80001d08:	03353423          	sd	s3,40(a0)
    80001d0c:	03453823          	sd	s4,48(a0)
    80001d10:	03553c23          	sd	s5,56(a0)
    80001d14:	05653023          	sd	s6,64(a0)
    80001d18:	05753423          	sd	s7,72(a0)
    80001d1c:	05853823          	sd	s8,80(a0)
    80001d20:	05953c23          	sd	s9,88(a0)
    80001d24:	07a53023          	sd	s10,96(a0)
    80001d28:	07b53423          	sd	s11,104(a0)
    80001d2c:	0005b083          	ld	ra,0(a1)
    80001d30:	0085b103          	ld	sp,8(a1)
    80001d34:	6980                	ld	s0,16(a1)
    80001d36:	6d84                	ld	s1,24(a1)
    80001d38:	0205b903          	ld	s2,32(a1)
    80001d3c:	0285b983          	ld	s3,40(a1)
    80001d40:	0305ba03          	ld	s4,48(a1)
    80001d44:	0385ba83          	ld	s5,56(a1)
    80001d48:	0405bb03          	ld	s6,64(a1)
    80001d4c:	0485bb83          	ld	s7,72(a1)
    80001d50:	0505bc03          	ld	s8,80(a1)
    80001d54:	0585bc83          	ld	s9,88(a1)
    80001d58:	0605bd03          	ld	s10,96(a1)
    80001d5c:	0685bd83          	ld	s11,104(a1)
    80001d60:	8082                	ret

0000000080001d62 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80001d62:	1141                	addi	sp,sp,-16
    80001d64:	e406                	sd	ra,8(sp)
    80001d66:	e022                	sd	s0,0(sp)
    80001d68:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80001d6a:	00006597          	auipc	a1,0x6
    80001d6e:	57658593          	addi	a1,a1,1398 # 800082e0 <states.0+0x30>
    80001d72:	0010d517          	auipc	a0,0x10d
    80001d76:	b4e50513          	addi	a0,a0,-1202 # 8010e8c0 <tickslock>
    80001d7a:	00004097          	auipc	ra,0x4
    80001d7e:	5b0080e7          	jalr	1456(ra) # 8000632a <initlock>
}
    80001d82:	60a2                	ld	ra,8(sp)
    80001d84:	6402                	ld	s0,0(sp)
    80001d86:	0141                	addi	sp,sp,16
    80001d88:	8082                	ret

0000000080001d8a <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80001d8a:	1141                	addi	sp,sp,-16
    80001d8c:	e422                	sd	s0,8(sp)
    80001d8e:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001d90:	00003797          	auipc	a5,0x3
    80001d94:	52078793          	addi	a5,a5,1312 # 800052b0 <kernelvec>
    80001d98:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80001d9c:	6422                	ld	s0,8(sp)
    80001d9e:	0141                	addi	sp,sp,16
    80001da0:	8082                	ret

0000000080001da2 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80001da2:	1141                	addi	sp,sp,-16
    80001da4:	e406                	sd	ra,8(sp)
    80001da6:	e022                	sd	s0,0(sp)
    80001da8:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80001daa:	fffff097          	auipc	ra,0xfffff
    80001dae:	340080e7          	jalr	832(ra) # 800010ea <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001db2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001db6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001db8:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80001dbc:	00005617          	auipc	a2,0x5
    80001dc0:	24460613          	addi	a2,a2,580 # 80007000 <_trampoline>
    80001dc4:	00005697          	auipc	a3,0x5
    80001dc8:	23c68693          	addi	a3,a3,572 # 80007000 <_trampoline>
    80001dcc:	8e91                	sub	a3,a3,a2
    80001dce:	040007b7          	lui	a5,0x4000
    80001dd2:	17fd                	addi	a5,a5,-1
    80001dd4:	07b2                	slli	a5,a5,0xc
    80001dd6:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001dd8:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80001ddc:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80001dde:	180026f3          	csrr	a3,satp
    80001de2:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80001de4:	6d38                	ld	a4,88(a0)
    80001de6:	6134                	ld	a3,64(a0)
    80001de8:	6585                	lui	a1,0x1
    80001dea:	96ae                	add	a3,a3,a1
    80001dec:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80001dee:	6d38                	ld	a4,88(a0)
    80001df0:	00000697          	auipc	a3,0x0
    80001df4:	13068693          	addi	a3,a3,304 # 80001f20 <usertrap>
    80001df8:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80001dfa:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80001dfc:	8692                	mv	a3,tp
    80001dfe:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e00:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80001e04:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80001e08:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e0c:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80001e10:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001e12:	6f18                	ld	a4,24(a4)
    80001e14:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80001e18:	6928                	ld	a0,80(a0)
    80001e1a:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001e1c:	00005717          	auipc	a4,0x5
    80001e20:	28070713          	addi	a4,a4,640 # 8000709c <userret>
    80001e24:	8f11                	sub	a4,a4,a2
    80001e26:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001e28:	577d                	li	a4,-1
    80001e2a:	177e                	slli	a4,a4,0x3f
    80001e2c:	8d59                	or	a0,a0,a4
    80001e2e:	9782                	jalr	a5
}
    80001e30:	60a2                	ld	ra,8(sp)
    80001e32:	6402                	ld	s0,0(sp)
    80001e34:	0141                	addi	sp,sp,16
    80001e36:	8082                	ret

0000000080001e38 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80001e38:	1101                	addi	sp,sp,-32
    80001e3a:	ec06                	sd	ra,24(sp)
    80001e3c:	e822                	sd	s0,16(sp)
    80001e3e:	e426                	sd	s1,8(sp)
    80001e40:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80001e42:	0010d497          	auipc	s1,0x10d
    80001e46:	a7e48493          	addi	s1,s1,-1410 # 8010e8c0 <tickslock>
    80001e4a:	8526                	mv	a0,s1
    80001e4c:	00004097          	auipc	ra,0x4
    80001e50:	56e080e7          	jalr	1390(ra) # 800063ba <acquire>
  ticks++;
    80001e54:	00007517          	auipc	a0,0x7
    80001e58:	ac450513          	addi	a0,a0,-1340 # 80008918 <ticks>
    80001e5c:	411c                	lw	a5,0(a0)
    80001e5e:	2785                	addiw	a5,a5,1
    80001e60:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80001e62:	00000097          	auipc	ra,0x0
    80001e66:	998080e7          	jalr	-1640(ra) # 800017fa <wakeup>
  release(&tickslock);
    80001e6a:	8526                	mv	a0,s1
    80001e6c:	00004097          	auipc	ra,0x4
    80001e70:	602080e7          	jalr	1538(ra) # 8000646e <release>
}
    80001e74:	60e2                	ld	ra,24(sp)
    80001e76:	6442                	ld	s0,16(sp)
    80001e78:	64a2                	ld	s1,8(sp)
    80001e7a:	6105                	addi	sp,sp,32
    80001e7c:	8082                	ret

0000000080001e7e <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80001e7e:	1101                	addi	sp,sp,-32
    80001e80:	ec06                	sd	ra,24(sp)
    80001e82:	e822                	sd	s0,16(sp)
    80001e84:	e426                	sd	s1,8(sp)
    80001e86:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001e88:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80001e8c:	00074d63          	bltz	a4,80001ea6 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80001e90:	57fd                	li	a5,-1
    80001e92:	17fe                	slli	a5,a5,0x3f
    80001e94:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80001e96:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80001e98:	06f70363          	beq	a4,a5,80001efe <devintr+0x80>
  }
}
    80001e9c:	60e2                	ld	ra,24(sp)
    80001e9e:	6442                	ld	s0,16(sp)
    80001ea0:	64a2                	ld	s1,8(sp)
    80001ea2:	6105                	addi	sp,sp,32
    80001ea4:	8082                	ret
     (scause & 0xff) == 9){
    80001ea6:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80001eaa:	46a5                	li	a3,9
    80001eac:	fed792e3          	bne	a5,a3,80001e90 <devintr+0x12>
    int irq = plic_claim();
    80001eb0:	00003097          	auipc	ra,0x3
    80001eb4:	508080e7          	jalr	1288(ra) # 800053b8 <plic_claim>
    80001eb8:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80001eba:	47a9                	li	a5,10
    80001ebc:	02f50763          	beq	a0,a5,80001eea <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80001ec0:	4785                	li	a5,1
    80001ec2:	02f50963          	beq	a0,a5,80001ef4 <devintr+0x76>
    return 1;
    80001ec6:	4505                	li	a0,1
    } else if(irq){
    80001ec8:	d8f1                	beqz	s1,80001e9c <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80001eca:	85a6                	mv	a1,s1
    80001ecc:	00006517          	auipc	a0,0x6
    80001ed0:	41c50513          	addi	a0,a0,1052 # 800082e8 <states.0+0x38>
    80001ed4:	00004097          	auipc	ra,0x4
    80001ed8:	ff4080e7          	jalr	-12(ra) # 80005ec8 <printf>
      plic_complete(irq);
    80001edc:	8526                	mv	a0,s1
    80001ede:	00003097          	auipc	ra,0x3
    80001ee2:	4fe080e7          	jalr	1278(ra) # 800053dc <plic_complete>
    return 1;
    80001ee6:	4505                	li	a0,1
    80001ee8:	bf55                	j	80001e9c <devintr+0x1e>
      uartintr();
    80001eea:	00004097          	auipc	ra,0x4
    80001eee:	3f0080e7          	jalr	1008(ra) # 800062da <uartintr>
    80001ef2:	b7ed                	j	80001edc <devintr+0x5e>
      virtio_disk_intr();
    80001ef4:	00004097          	auipc	ra,0x4
    80001ef8:	9b4080e7          	jalr	-1612(ra) # 800058a8 <virtio_disk_intr>
    80001efc:	b7c5                	j	80001edc <devintr+0x5e>
    if(cpuid() == 0){
    80001efe:	fffff097          	auipc	ra,0xfffff
    80001f02:	1c0080e7          	jalr	448(ra) # 800010be <cpuid>
    80001f06:	c901                	beqz	a0,80001f16 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80001f08:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80001f0c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80001f0e:	14479073          	csrw	sip,a5
    return 2;
    80001f12:	4509                	li	a0,2
    80001f14:	b761                	j	80001e9c <devintr+0x1e>
      clockintr();
    80001f16:	00000097          	auipc	ra,0x0
    80001f1a:	f22080e7          	jalr	-222(ra) # 80001e38 <clockintr>
    80001f1e:	b7ed                	j	80001f08 <devintr+0x8a>

0000000080001f20 <usertrap>:
{
    80001f20:	1101                	addi	sp,sp,-32
    80001f22:	ec06                	sd	ra,24(sp)
    80001f24:	e822                	sd	s0,16(sp)
    80001f26:	e426                	sd	s1,8(sp)
    80001f28:	e04a                	sd	s2,0(sp)
    80001f2a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f2c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001f30:	1007f793          	andi	a5,a5,256
    80001f34:	e7b9                	bnez	a5,80001f82 <usertrap+0x62>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001f36:	00003797          	auipc	a5,0x3
    80001f3a:	37a78793          	addi	a5,a5,890 # 800052b0 <kernelvec>
    80001f3e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80001f42:	fffff097          	auipc	ra,0xfffff
    80001f46:	1a8080e7          	jalr	424(ra) # 800010ea <myproc>
    80001f4a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80001f4c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001f4e:	14102773          	csrr	a4,sepc
    80001f52:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001f54:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80001f58:	47a1                	li	a5,8
    80001f5a:	02f70c63          	beq	a4,a5,80001f92 <usertrap+0x72>
    80001f5e:	14202773          	csrr	a4,scause
   else if (r_scause() == 15)
    80001f62:	47bd                	li	a5,15
    80001f64:	08f70063          	beq	a4,a5,80001fe4 <usertrap+0xc4>
  else if((which_dev = devintr()) != 0){
    80001f68:	00000097          	auipc	ra,0x0
    80001f6c:	f16080e7          	jalr	-234(ra) # 80001e7e <devintr>
    80001f70:	892a                	mv	s2,a0
    80001f72:	cd55                	beqz	a0,8000202e <usertrap+0x10e>
  if(killed(p))
    80001f74:	8526                	mv	a0,s1
    80001f76:	00000097          	auipc	ra,0x0
    80001f7a:	ac8080e7          	jalr	-1336(ra) # 80001a3e <killed>
    80001f7e:	c97d                	beqz	a0,80002074 <usertrap+0x154>
    80001f80:	a0ed                	j	8000206a <usertrap+0x14a>
    panic("usertrap: not from user mode");
    80001f82:	00006517          	auipc	a0,0x6
    80001f86:	38650513          	addi	a0,a0,902 # 80008308 <states.0+0x58>
    80001f8a:	00004097          	auipc	ra,0x4
    80001f8e:	ef4080e7          	jalr	-268(ra) # 80005e7e <panic>
    if(killed(p))
    80001f92:	00000097          	auipc	ra,0x0
    80001f96:	aac080e7          	jalr	-1364(ra) # 80001a3e <killed>
    80001f9a:	ed1d                	bnez	a0,80001fd8 <usertrap+0xb8>
    p->trapframe->epc += 4;
    80001f9c:	6cb8                	ld	a4,88(s1)
    80001f9e:	6f1c                	ld	a5,24(a4)
    80001fa0:	0791                	addi	a5,a5,4
    80001fa2:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fa4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fa8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fac:	10079073          	csrw	sstatus,a5
    syscall();
    80001fb0:	00000097          	auipc	ra,0x0
    80001fb4:	31e080e7          	jalr	798(ra) # 800022ce <syscall>
  if(killed(p))
    80001fb8:	8526                	mv	a0,s1
    80001fba:	00000097          	auipc	ra,0x0
    80001fbe:	a84080e7          	jalr	-1404(ra) # 80001a3e <killed>
    80001fc2:	e15d                	bnez	a0,80002068 <usertrap+0x148>
  usertrapret();
    80001fc4:	00000097          	auipc	ra,0x0
    80001fc8:	dde080e7          	jalr	-546(ra) # 80001da2 <usertrapret>
}
    80001fcc:	60e2                	ld	ra,24(sp)
    80001fce:	6442                	ld	s0,16(sp)
    80001fd0:	64a2                	ld	s1,8(sp)
    80001fd2:	6902                	ld	s2,0(sp)
    80001fd4:	6105                	addi	sp,sp,32
    80001fd6:	8082                	ret
      exit(-1);
    80001fd8:	557d                	li	a0,-1
    80001fda:	00000097          	auipc	ra,0x0
    80001fde:	8f0080e7          	jalr	-1808(ra) # 800018ca <exit>
    80001fe2:	bf6d                	j	80001f9c <usertrap+0x7c>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001fe4:	143025f3          	csrr	a1,stval
    uint64 pa = cow_copy(p->pagetable, stval);
    80001fe8:	6928                	ld	a0,80(a0)
    80001fea:	fffff097          	auipc	ra,0xfffff
    80001fee:	dde080e7          	jalr	-546(ra) # 80000dc8 <cow_copy>
    if (pa == 0)
    80001ff2:	f179                	bnez	a0,80001fb8 <usertrap+0x98>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001ff4:	142025f3          	csrr	a1,scause
      printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80001ff8:	5890                	lw	a2,48(s1)
    80001ffa:	00006517          	auipc	a0,0x6
    80001ffe:	32e50513          	addi	a0,a0,814 # 80008328 <states.0+0x78>
    80002002:	00004097          	auipc	ra,0x4
    80002006:	ec6080e7          	jalr	-314(ra) # 80005ec8 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000200a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000200e:	14302673          	csrr	a2,stval
      printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002012:	00006517          	auipc	a0,0x6
    80002016:	34650513          	addi	a0,a0,838 # 80008358 <states.0+0xa8>
    8000201a:	00004097          	auipc	ra,0x4
    8000201e:	eae080e7          	jalr	-338(ra) # 80005ec8 <printf>
      setkilled(p);
    80002022:	8526                	mv	a0,s1
    80002024:	00000097          	auipc	ra,0x0
    80002028:	9ee080e7          	jalr	-1554(ra) # 80001a12 <setkilled>
    8000202c:	b771                	j	80001fb8 <usertrap+0x98>
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000202e:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002032:	5890                	lw	a2,48(s1)
    80002034:	00006517          	auipc	a0,0x6
    80002038:	2f450513          	addi	a0,a0,756 # 80008328 <states.0+0x78>
    8000203c:	00004097          	auipc	ra,0x4
    80002040:	e8c080e7          	jalr	-372(ra) # 80005ec8 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002044:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002048:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000204c:	00006517          	auipc	a0,0x6
    80002050:	30c50513          	addi	a0,a0,780 # 80008358 <states.0+0xa8>
    80002054:	00004097          	auipc	ra,0x4
    80002058:	e74080e7          	jalr	-396(ra) # 80005ec8 <printf>
    setkilled(p);
    8000205c:	8526                	mv	a0,s1
    8000205e:	00000097          	auipc	ra,0x0
    80002062:	9b4080e7          	jalr	-1612(ra) # 80001a12 <setkilled>
    80002066:	bf89                	j	80001fb8 <usertrap+0x98>
  if(killed(p))
    80002068:	4901                	li	s2,0
    exit(-1);
    8000206a:	557d                	li	a0,-1
    8000206c:	00000097          	auipc	ra,0x0
    80002070:	85e080e7          	jalr	-1954(ra) # 800018ca <exit>
  if(which_dev == 2)
    80002074:	4789                	li	a5,2
    80002076:	f4f917e3          	bne	s2,a5,80001fc4 <usertrap+0xa4>
    yield();
    8000207a:	fffff097          	auipc	ra,0xfffff
    8000207e:	6e0080e7          	jalr	1760(ra) # 8000175a <yield>
    80002082:	b789                	j	80001fc4 <usertrap+0xa4>

0000000080002084 <kerneltrap>:
{
    80002084:	7179                	addi	sp,sp,-48
    80002086:	f406                	sd	ra,40(sp)
    80002088:	f022                	sd	s0,32(sp)
    8000208a:	ec26                	sd	s1,24(sp)
    8000208c:	e84a                	sd	s2,16(sp)
    8000208e:	e44e                	sd	s3,8(sp)
    80002090:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002092:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002096:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000209a:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000209e:	1004f793          	andi	a5,s1,256
    800020a2:	cb85                	beqz	a5,800020d2 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020a4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800020a8:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800020aa:	ef85                	bnez	a5,800020e2 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800020ac:	00000097          	auipc	ra,0x0
    800020b0:	dd2080e7          	jalr	-558(ra) # 80001e7e <devintr>
    800020b4:	cd1d                	beqz	a0,800020f2 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800020b6:	4789                	li	a5,2
    800020b8:	06f50a63          	beq	a0,a5,8000212c <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800020bc:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800020c0:	10049073          	csrw	sstatus,s1
}
    800020c4:	70a2                	ld	ra,40(sp)
    800020c6:	7402                	ld	s0,32(sp)
    800020c8:	64e2                	ld	s1,24(sp)
    800020ca:	6942                	ld	s2,16(sp)
    800020cc:	69a2                	ld	s3,8(sp)
    800020ce:	6145                	addi	sp,sp,48
    800020d0:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800020d2:	00006517          	auipc	a0,0x6
    800020d6:	2a650513          	addi	a0,a0,678 # 80008378 <states.0+0xc8>
    800020da:	00004097          	auipc	ra,0x4
    800020de:	da4080e7          	jalr	-604(ra) # 80005e7e <panic>
    panic("kerneltrap: interrupts enabled");
    800020e2:	00006517          	auipc	a0,0x6
    800020e6:	2be50513          	addi	a0,a0,702 # 800083a0 <states.0+0xf0>
    800020ea:	00004097          	auipc	ra,0x4
    800020ee:	d94080e7          	jalr	-620(ra) # 80005e7e <panic>
    printf("scause %p\n", scause);
    800020f2:	85ce                	mv	a1,s3
    800020f4:	00006517          	auipc	a0,0x6
    800020f8:	2cc50513          	addi	a0,a0,716 # 800083c0 <states.0+0x110>
    800020fc:	00004097          	auipc	ra,0x4
    80002100:	dcc080e7          	jalr	-564(ra) # 80005ec8 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002104:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002108:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000210c:	00006517          	auipc	a0,0x6
    80002110:	2c450513          	addi	a0,a0,708 # 800083d0 <states.0+0x120>
    80002114:	00004097          	auipc	ra,0x4
    80002118:	db4080e7          	jalr	-588(ra) # 80005ec8 <printf>
    panic("kerneltrap");
    8000211c:	00006517          	auipc	a0,0x6
    80002120:	2cc50513          	addi	a0,a0,716 # 800083e8 <states.0+0x138>
    80002124:	00004097          	auipc	ra,0x4
    80002128:	d5a080e7          	jalr	-678(ra) # 80005e7e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000212c:	fffff097          	auipc	ra,0xfffff
    80002130:	fbe080e7          	jalr	-66(ra) # 800010ea <myproc>
    80002134:	d541                	beqz	a0,800020bc <kerneltrap+0x38>
    80002136:	fffff097          	auipc	ra,0xfffff
    8000213a:	fb4080e7          	jalr	-76(ra) # 800010ea <myproc>
    8000213e:	4d18                	lw	a4,24(a0)
    80002140:	4791                	li	a5,4
    80002142:	f6f71de3          	bne	a4,a5,800020bc <kerneltrap+0x38>
    yield();
    80002146:	fffff097          	auipc	ra,0xfffff
    8000214a:	614080e7          	jalr	1556(ra) # 8000175a <yield>
    8000214e:	b7bd                	j	800020bc <kerneltrap+0x38>

0000000080002150 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002150:	1101                	addi	sp,sp,-32
    80002152:	ec06                	sd	ra,24(sp)
    80002154:	e822                	sd	s0,16(sp)
    80002156:	e426                	sd	s1,8(sp)
    80002158:	1000                	addi	s0,sp,32
    8000215a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000215c:	fffff097          	auipc	ra,0xfffff
    80002160:	f8e080e7          	jalr	-114(ra) # 800010ea <myproc>
  switch (n) {
    80002164:	4795                	li	a5,5
    80002166:	0497e163          	bltu	a5,s1,800021a8 <argraw+0x58>
    8000216a:	048a                	slli	s1,s1,0x2
    8000216c:	00006717          	auipc	a4,0x6
    80002170:	2b470713          	addi	a4,a4,692 # 80008420 <states.0+0x170>
    80002174:	94ba                	add	s1,s1,a4
    80002176:	409c                	lw	a5,0(s1)
    80002178:	97ba                	add	a5,a5,a4
    8000217a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000217c:	6d3c                	ld	a5,88(a0)
    8000217e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002180:	60e2                	ld	ra,24(sp)
    80002182:	6442                	ld	s0,16(sp)
    80002184:	64a2                	ld	s1,8(sp)
    80002186:	6105                	addi	sp,sp,32
    80002188:	8082                	ret
    return p->trapframe->a1;
    8000218a:	6d3c                	ld	a5,88(a0)
    8000218c:	7fa8                	ld	a0,120(a5)
    8000218e:	bfcd                	j	80002180 <argraw+0x30>
    return p->trapframe->a2;
    80002190:	6d3c                	ld	a5,88(a0)
    80002192:	63c8                	ld	a0,128(a5)
    80002194:	b7f5                	j	80002180 <argraw+0x30>
    return p->trapframe->a3;
    80002196:	6d3c                	ld	a5,88(a0)
    80002198:	67c8                	ld	a0,136(a5)
    8000219a:	b7dd                	j	80002180 <argraw+0x30>
    return p->trapframe->a4;
    8000219c:	6d3c                	ld	a5,88(a0)
    8000219e:	6bc8                	ld	a0,144(a5)
    800021a0:	b7c5                	j	80002180 <argraw+0x30>
    return p->trapframe->a5;
    800021a2:	6d3c                	ld	a5,88(a0)
    800021a4:	6fc8                	ld	a0,152(a5)
    800021a6:	bfe9                	j	80002180 <argraw+0x30>
  panic("argraw");
    800021a8:	00006517          	auipc	a0,0x6
    800021ac:	25050513          	addi	a0,a0,592 # 800083f8 <states.0+0x148>
    800021b0:	00004097          	auipc	ra,0x4
    800021b4:	cce080e7          	jalr	-818(ra) # 80005e7e <panic>

00000000800021b8 <fetchaddr>:
{
    800021b8:	1101                	addi	sp,sp,-32
    800021ba:	ec06                	sd	ra,24(sp)
    800021bc:	e822                	sd	s0,16(sp)
    800021be:	e426                	sd	s1,8(sp)
    800021c0:	e04a                	sd	s2,0(sp)
    800021c2:	1000                	addi	s0,sp,32
    800021c4:	84aa                	mv	s1,a0
    800021c6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800021c8:	fffff097          	auipc	ra,0xfffff
    800021cc:	f22080e7          	jalr	-222(ra) # 800010ea <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800021d0:	653c                	ld	a5,72(a0)
    800021d2:	02f4f863          	bgeu	s1,a5,80002202 <fetchaddr+0x4a>
    800021d6:	00848713          	addi	a4,s1,8
    800021da:	02e7e663          	bltu	a5,a4,80002206 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800021de:	46a1                	li	a3,8
    800021e0:	8626                	mv	a2,s1
    800021e2:	85ca                	mv	a1,s2
    800021e4:	6928                	ld	a0,80(a0)
    800021e6:	fffff097          	auipc	ra,0xfffff
    800021ea:	aa0080e7          	jalr	-1376(ra) # 80000c86 <copyin>
    800021ee:	00a03533          	snez	a0,a0
    800021f2:	40a00533          	neg	a0,a0
}
    800021f6:	60e2                	ld	ra,24(sp)
    800021f8:	6442                	ld	s0,16(sp)
    800021fa:	64a2                	ld	s1,8(sp)
    800021fc:	6902                	ld	s2,0(sp)
    800021fe:	6105                	addi	sp,sp,32
    80002200:	8082                	ret
    return -1;
    80002202:	557d                	li	a0,-1
    80002204:	bfcd                	j	800021f6 <fetchaddr+0x3e>
    80002206:	557d                	li	a0,-1
    80002208:	b7fd                	j	800021f6 <fetchaddr+0x3e>

000000008000220a <fetchstr>:
{
    8000220a:	7179                	addi	sp,sp,-48
    8000220c:	f406                	sd	ra,40(sp)
    8000220e:	f022                	sd	s0,32(sp)
    80002210:	ec26                	sd	s1,24(sp)
    80002212:	e84a                	sd	s2,16(sp)
    80002214:	e44e                	sd	s3,8(sp)
    80002216:	1800                	addi	s0,sp,48
    80002218:	892a                	mv	s2,a0
    8000221a:	84ae                	mv	s1,a1
    8000221c:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000221e:	fffff097          	auipc	ra,0xfffff
    80002222:	ecc080e7          	jalr	-308(ra) # 800010ea <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002226:	86ce                	mv	a3,s3
    80002228:	864a                	mv	a2,s2
    8000222a:	85a6                	mv	a1,s1
    8000222c:	6928                	ld	a0,80(a0)
    8000222e:	fffff097          	auipc	ra,0xfffff
    80002232:	ae6080e7          	jalr	-1306(ra) # 80000d14 <copyinstr>
    80002236:	00054e63          	bltz	a0,80002252 <fetchstr+0x48>
  return strlen(buf);
    8000223a:	8526                	mv	a0,s1
    8000223c:	ffffe097          	auipc	ra,0xffffe
    80002240:	206080e7          	jalr	518(ra) # 80000442 <strlen>
}
    80002244:	70a2                	ld	ra,40(sp)
    80002246:	7402                	ld	s0,32(sp)
    80002248:	64e2                	ld	s1,24(sp)
    8000224a:	6942                	ld	s2,16(sp)
    8000224c:	69a2                	ld	s3,8(sp)
    8000224e:	6145                	addi	sp,sp,48
    80002250:	8082                	ret
    return -1;
    80002252:	557d                	li	a0,-1
    80002254:	bfc5                	j	80002244 <fetchstr+0x3a>

0000000080002256 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002256:	1101                	addi	sp,sp,-32
    80002258:	ec06                	sd	ra,24(sp)
    8000225a:	e822                	sd	s0,16(sp)
    8000225c:	e426                	sd	s1,8(sp)
    8000225e:	1000                	addi	s0,sp,32
    80002260:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002262:	00000097          	auipc	ra,0x0
    80002266:	eee080e7          	jalr	-274(ra) # 80002150 <argraw>
    8000226a:	c088                	sw	a0,0(s1)
}
    8000226c:	60e2                	ld	ra,24(sp)
    8000226e:	6442                	ld	s0,16(sp)
    80002270:	64a2                	ld	s1,8(sp)
    80002272:	6105                	addi	sp,sp,32
    80002274:	8082                	ret

0000000080002276 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002276:	1101                	addi	sp,sp,-32
    80002278:	ec06                	sd	ra,24(sp)
    8000227a:	e822                	sd	s0,16(sp)
    8000227c:	e426                	sd	s1,8(sp)
    8000227e:	1000                	addi	s0,sp,32
    80002280:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002282:	00000097          	auipc	ra,0x0
    80002286:	ece080e7          	jalr	-306(ra) # 80002150 <argraw>
    8000228a:	e088                	sd	a0,0(s1)
}
    8000228c:	60e2                	ld	ra,24(sp)
    8000228e:	6442                	ld	s0,16(sp)
    80002290:	64a2                	ld	s1,8(sp)
    80002292:	6105                	addi	sp,sp,32
    80002294:	8082                	ret

0000000080002296 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002296:	7179                	addi	sp,sp,-48
    80002298:	f406                	sd	ra,40(sp)
    8000229a:	f022                	sd	s0,32(sp)
    8000229c:	ec26                	sd	s1,24(sp)
    8000229e:	e84a                	sd	s2,16(sp)
    800022a0:	1800                	addi	s0,sp,48
    800022a2:	84ae                	mv	s1,a1
    800022a4:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    800022a6:	fd840593          	addi	a1,s0,-40
    800022aa:	00000097          	auipc	ra,0x0
    800022ae:	fcc080e7          	jalr	-52(ra) # 80002276 <argaddr>
  return fetchstr(addr, buf, max);
    800022b2:	864a                	mv	a2,s2
    800022b4:	85a6                	mv	a1,s1
    800022b6:	fd843503          	ld	a0,-40(s0)
    800022ba:	00000097          	auipc	ra,0x0
    800022be:	f50080e7          	jalr	-176(ra) # 8000220a <fetchstr>
}
    800022c2:	70a2                	ld	ra,40(sp)
    800022c4:	7402                	ld	s0,32(sp)
    800022c6:	64e2                	ld	s1,24(sp)
    800022c8:	6942                	ld	s2,16(sp)
    800022ca:	6145                	addi	sp,sp,48
    800022cc:	8082                	ret

00000000800022ce <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    800022ce:	1101                	addi	sp,sp,-32
    800022d0:	ec06                	sd	ra,24(sp)
    800022d2:	e822                	sd	s0,16(sp)
    800022d4:	e426                	sd	s1,8(sp)
    800022d6:	e04a                	sd	s2,0(sp)
    800022d8:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800022da:	fffff097          	auipc	ra,0xfffff
    800022de:	e10080e7          	jalr	-496(ra) # 800010ea <myproc>
    800022e2:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800022e4:	05853903          	ld	s2,88(a0)
    800022e8:	0a893783          	ld	a5,168(s2)
    800022ec:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800022f0:	37fd                	addiw	a5,a5,-1
    800022f2:	4751                	li	a4,20
    800022f4:	00f76f63          	bltu	a4,a5,80002312 <syscall+0x44>
    800022f8:	00369713          	slli	a4,a3,0x3
    800022fc:	00006797          	auipc	a5,0x6
    80002300:	13c78793          	addi	a5,a5,316 # 80008438 <syscalls>
    80002304:	97ba                	add	a5,a5,a4
    80002306:	639c                	ld	a5,0(a5)
    80002308:	c789                	beqz	a5,80002312 <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    8000230a:	9782                	jalr	a5
    8000230c:	06a93823          	sd	a0,112(s2)
    80002310:	a839                	j	8000232e <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002312:	15848613          	addi	a2,s1,344
    80002316:	588c                	lw	a1,48(s1)
    80002318:	00006517          	auipc	a0,0x6
    8000231c:	0e850513          	addi	a0,a0,232 # 80008400 <states.0+0x150>
    80002320:	00004097          	auipc	ra,0x4
    80002324:	ba8080e7          	jalr	-1112(ra) # 80005ec8 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002328:	6cbc                	ld	a5,88(s1)
    8000232a:	577d                	li	a4,-1
    8000232c:	fbb8                	sd	a4,112(a5)
  }
}
    8000232e:	60e2                	ld	ra,24(sp)
    80002330:	6442                	ld	s0,16(sp)
    80002332:	64a2                	ld	s1,8(sp)
    80002334:	6902                	ld	s2,0(sp)
    80002336:	6105                	addi	sp,sp,32
    80002338:	8082                	ret

000000008000233a <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    8000233a:	1101                	addi	sp,sp,-32
    8000233c:	ec06                	sd	ra,24(sp)
    8000233e:	e822                	sd	s0,16(sp)
    80002340:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002342:	fec40593          	addi	a1,s0,-20
    80002346:	4501                	li	a0,0
    80002348:	00000097          	auipc	ra,0x0
    8000234c:	f0e080e7          	jalr	-242(ra) # 80002256 <argint>
  exit(n);
    80002350:	fec42503          	lw	a0,-20(s0)
    80002354:	fffff097          	auipc	ra,0xfffff
    80002358:	576080e7          	jalr	1398(ra) # 800018ca <exit>
  return 0;  // not reached
}
    8000235c:	4501                	li	a0,0
    8000235e:	60e2                	ld	ra,24(sp)
    80002360:	6442                	ld	s0,16(sp)
    80002362:	6105                	addi	sp,sp,32
    80002364:	8082                	ret

0000000080002366 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002366:	1141                	addi	sp,sp,-16
    80002368:	e406                	sd	ra,8(sp)
    8000236a:	e022                	sd	s0,0(sp)
    8000236c:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000236e:	fffff097          	auipc	ra,0xfffff
    80002372:	d7c080e7          	jalr	-644(ra) # 800010ea <myproc>
}
    80002376:	5908                	lw	a0,48(a0)
    80002378:	60a2                	ld	ra,8(sp)
    8000237a:	6402                	ld	s0,0(sp)
    8000237c:	0141                	addi	sp,sp,16
    8000237e:	8082                	ret

0000000080002380 <sys_fork>:

uint64
sys_fork(void)
{
    80002380:	1141                	addi	sp,sp,-16
    80002382:	e406                	sd	ra,8(sp)
    80002384:	e022                	sd	s0,0(sp)
    80002386:	0800                	addi	s0,sp,16
  return fork();
    80002388:	fffff097          	auipc	ra,0xfffff
    8000238c:	11c080e7          	jalr	284(ra) # 800014a4 <fork>
}
    80002390:	60a2                	ld	ra,8(sp)
    80002392:	6402                	ld	s0,0(sp)
    80002394:	0141                	addi	sp,sp,16
    80002396:	8082                	ret

0000000080002398 <sys_wait>:

uint64
sys_wait(void)
{
    80002398:	1101                	addi	sp,sp,-32
    8000239a:	ec06                	sd	ra,24(sp)
    8000239c:	e822                	sd	s0,16(sp)
    8000239e:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800023a0:	fe840593          	addi	a1,s0,-24
    800023a4:	4501                	li	a0,0
    800023a6:	00000097          	auipc	ra,0x0
    800023aa:	ed0080e7          	jalr	-304(ra) # 80002276 <argaddr>
  return wait(p);
    800023ae:	fe843503          	ld	a0,-24(s0)
    800023b2:	fffff097          	auipc	ra,0xfffff
    800023b6:	6be080e7          	jalr	1726(ra) # 80001a70 <wait>
}
    800023ba:	60e2                	ld	ra,24(sp)
    800023bc:	6442                	ld	s0,16(sp)
    800023be:	6105                	addi	sp,sp,32
    800023c0:	8082                	ret

00000000800023c2 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800023c2:	7179                	addi	sp,sp,-48
    800023c4:	f406                	sd	ra,40(sp)
    800023c6:	f022                	sd	s0,32(sp)
    800023c8:	ec26                	sd	s1,24(sp)
    800023ca:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    800023cc:	fdc40593          	addi	a1,s0,-36
    800023d0:	4501                	li	a0,0
    800023d2:	00000097          	auipc	ra,0x0
    800023d6:	e84080e7          	jalr	-380(ra) # 80002256 <argint>
  addr = myproc()->sz;
    800023da:	fffff097          	auipc	ra,0xfffff
    800023de:	d10080e7          	jalr	-752(ra) # 800010ea <myproc>
    800023e2:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    800023e4:	fdc42503          	lw	a0,-36(s0)
    800023e8:	fffff097          	auipc	ra,0xfffff
    800023ec:	060080e7          	jalr	96(ra) # 80001448 <growproc>
    800023f0:	00054863          	bltz	a0,80002400 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    800023f4:	8526                	mv	a0,s1
    800023f6:	70a2                	ld	ra,40(sp)
    800023f8:	7402                	ld	s0,32(sp)
    800023fa:	64e2                	ld	s1,24(sp)
    800023fc:	6145                	addi	sp,sp,48
    800023fe:	8082                	ret
    return -1;
    80002400:	54fd                	li	s1,-1
    80002402:	bfcd                	j	800023f4 <sys_sbrk+0x32>

0000000080002404 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002404:	7139                	addi	sp,sp,-64
    80002406:	fc06                	sd	ra,56(sp)
    80002408:	f822                	sd	s0,48(sp)
    8000240a:	f426                	sd	s1,40(sp)
    8000240c:	f04a                	sd	s2,32(sp)
    8000240e:	ec4e                	sd	s3,24(sp)
    80002410:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002412:	fcc40593          	addi	a1,s0,-52
    80002416:	4501                	li	a0,0
    80002418:	00000097          	auipc	ra,0x0
    8000241c:	e3e080e7          	jalr	-450(ra) # 80002256 <argint>
  if(n < 0)
    80002420:	fcc42783          	lw	a5,-52(s0)
    80002424:	0607cf63          	bltz	a5,800024a2 <sys_sleep+0x9e>
    n = 0;
  acquire(&tickslock);
    80002428:	0010c517          	auipc	a0,0x10c
    8000242c:	49850513          	addi	a0,a0,1176 # 8010e8c0 <tickslock>
    80002430:	00004097          	auipc	ra,0x4
    80002434:	f8a080e7          	jalr	-118(ra) # 800063ba <acquire>
  ticks0 = ticks;
    80002438:	00006917          	auipc	s2,0x6
    8000243c:	4e092903          	lw	s2,1248(s2) # 80008918 <ticks>
  while(ticks - ticks0 < n){
    80002440:	fcc42783          	lw	a5,-52(s0)
    80002444:	cf9d                	beqz	a5,80002482 <sys_sleep+0x7e>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002446:	0010c997          	auipc	s3,0x10c
    8000244a:	47a98993          	addi	s3,s3,1146 # 8010e8c0 <tickslock>
    8000244e:	00006497          	auipc	s1,0x6
    80002452:	4ca48493          	addi	s1,s1,1226 # 80008918 <ticks>
    if(killed(myproc())){
    80002456:	fffff097          	auipc	ra,0xfffff
    8000245a:	c94080e7          	jalr	-876(ra) # 800010ea <myproc>
    8000245e:	fffff097          	auipc	ra,0xfffff
    80002462:	5e0080e7          	jalr	1504(ra) # 80001a3e <killed>
    80002466:	e129                	bnez	a0,800024a8 <sys_sleep+0xa4>
    sleep(&ticks, &tickslock);
    80002468:	85ce                	mv	a1,s3
    8000246a:	8526                	mv	a0,s1
    8000246c:	fffff097          	auipc	ra,0xfffff
    80002470:	32a080e7          	jalr	810(ra) # 80001796 <sleep>
  while(ticks - ticks0 < n){
    80002474:	409c                	lw	a5,0(s1)
    80002476:	412787bb          	subw	a5,a5,s2
    8000247a:	fcc42703          	lw	a4,-52(s0)
    8000247e:	fce7ece3          	bltu	a5,a4,80002456 <sys_sleep+0x52>
  }
  release(&tickslock);
    80002482:	0010c517          	auipc	a0,0x10c
    80002486:	43e50513          	addi	a0,a0,1086 # 8010e8c0 <tickslock>
    8000248a:	00004097          	auipc	ra,0x4
    8000248e:	fe4080e7          	jalr	-28(ra) # 8000646e <release>
  return 0;
    80002492:	4501                	li	a0,0
}
    80002494:	70e2                	ld	ra,56(sp)
    80002496:	7442                	ld	s0,48(sp)
    80002498:	74a2                	ld	s1,40(sp)
    8000249a:	7902                	ld	s2,32(sp)
    8000249c:	69e2                	ld	s3,24(sp)
    8000249e:	6121                	addi	sp,sp,64
    800024a0:	8082                	ret
    n = 0;
    800024a2:	fc042623          	sw	zero,-52(s0)
    800024a6:	b749                	j	80002428 <sys_sleep+0x24>
      release(&tickslock);
    800024a8:	0010c517          	auipc	a0,0x10c
    800024ac:	41850513          	addi	a0,a0,1048 # 8010e8c0 <tickslock>
    800024b0:	00004097          	auipc	ra,0x4
    800024b4:	fbe080e7          	jalr	-66(ra) # 8000646e <release>
      return -1;
    800024b8:	557d                	li	a0,-1
    800024ba:	bfe9                	j	80002494 <sys_sleep+0x90>

00000000800024bc <sys_kill>:

uint64
sys_kill(void)
{
    800024bc:	1101                	addi	sp,sp,-32
    800024be:	ec06                	sd	ra,24(sp)
    800024c0:	e822                	sd	s0,16(sp)
    800024c2:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800024c4:	fec40593          	addi	a1,s0,-20
    800024c8:	4501                	li	a0,0
    800024ca:	00000097          	auipc	ra,0x0
    800024ce:	d8c080e7          	jalr	-628(ra) # 80002256 <argint>
  return kill(pid);
    800024d2:	fec42503          	lw	a0,-20(s0)
    800024d6:	fffff097          	auipc	ra,0xfffff
    800024da:	4ca080e7          	jalr	1226(ra) # 800019a0 <kill>
}
    800024de:	60e2                	ld	ra,24(sp)
    800024e0:	6442                	ld	s0,16(sp)
    800024e2:	6105                	addi	sp,sp,32
    800024e4:	8082                	ret

00000000800024e6 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800024e6:	1101                	addi	sp,sp,-32
    800024e8:	ec06                	sd	ra,24(sp)
    800024ea:	e822                	sd	s0,16(sp)
    800024ec:	e426                	sd	s1,8(sp)
    800024ee:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800024f0:	0010c517          	auipc	a0,0x10c
    800024f4:	3d050513          	addi	a0,a0,976 # 8010e8c0 <tickslock>
    800024f8:	00004097          	auipc	ra,0x4
    800024fc:	ec2080e7          	jalr	-318(ra) # 800063ba <acquire>
  xticks = ticks;
    80002500:	00006497          	auipc	s1,0x6
    80002504:	4184a483          	lw	s1,1048(s1) # 80008918 <ticks>
  release(&tickslock);
    80002508:	0010c517          	auipc	a0,0x10c
    8000250c:	3b850513          	addi	a0,a0,952 # 8010e8c0 <tickslock>
    80002510:	00004097          	auipc	ra,0x4
    80002514:	f5e080e7          	jalr	-162(ra) # 8000646e <release>
  return xticks;
}
    80002518:	02049513          	slli	a0,s1,0x20
    8000251c:	9101                	srli	a0,a0,0x20
    8000251e:	60e2                	ld	ra,24(sp)
    80002520:	6442                	ld	s0,16(sp)
    80002522:	64a2                	ld	s1,8(sp)
    80002524:	6105                	addi	sp,sp,32
    80002526:	8082                	ret

0000000080002528 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002528:	7179                	addi	sp,sp,-48
    8000252a:	f406                	sd	ra,40(sp)
    8000252c:	f022                	sd	s0,32(sp)
    8000252e:	ec26                	sd	s1,24(sp)
    80002530:	e84a                	sd	s2,16(sp)
    80002532:	e44e                	sd	s3,8(sp)
    80002534:	e052                	sd	s4,0(sp)
    80002536:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002538:	00006597          	auipc	a1,0x6
    8000253c:	fb058593          	addi	a1,a1,-80 # 800084e8 <syscalls+0xb0>
    80002540:	0010c517          	auipc	a0,0x10c
    80002544:	39850513          	addi	a0,a0,920 # 8010e8d8 <bcache>
    80002548:	00004097          	auipc	ra,0x4
    8000254c:	de2080e7          	jalr	-542(ra) # 8000632a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002550:	00114797          	auipc	a5,0x114
    80002554:	38878793          	addi	a5,a5,904 # 801168d8 <bcache+0x8000>
    80002558:	00114717          	auipc	a4,0x114
    8000255c:	5e870713          	addi	a4,a4,1512 # 80116b40 <bcache+0x8268>
    80002560:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002564:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002568:	0010c497          	auipc	s1,0x10c
    8000256c:	38848493          	addi	s1,s1,904 # 8010e8f0 <bcache+0x18>
    b->next = bcache.head.next;
    80002570:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002572:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002574:	00006a17          	auipc	s4,0x6
    80002578:	f7ca0a13          	addi	s4,s4,-132 # 800084f0 <syscalls+0xb8>
    b->next = bcache.head.next;
    8000257c:	2b893783          	ld	a5,696(s2)
    80002580:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002582:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002586:	85d2                	mv	a1,s4
    80002588:	01048513          	addi	a0,s1,16
    8000258c:	00001097          	auipc	ra,0x1
    80002590:	4c4080e7          	jalr	1220(ra) # 80003a50 <initsleeplock>
    bcache.head.next->prev = b;
    80002594:	2b893783          	ld	a5,696(s2)
    80002598:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000259a:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000259e:	45848493          	addi	s1,s1,1112
    800025a2:	fd349de3          	bne	s1,s3,8000257c <binit+0x54>
  }
}
    800025a6:	70a2                	ld	ra,40(sp)
    800025a8:	7402                	ld	s0,32(sp)
    800025aa:	64e2                	ld	s1,24(sp)
    800025ac:	6942                	ld	s2,16(sp)
    800025ae:	69a2                	ld	s3,8(sp)
    800025b0:	6a02                	ld	s4,0(sp)
    800025b2:	6145                	addi	sp,sp,48
    800025b4:	8082                	ret

00000000800025b6 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800025b6:	7179                	addi	sp,sp,-48
    800025b8:	f406                	sd	ra,40(sp)
    800025ba:	f022                	sd	s0,32(sp)
    800025bc:	ec26                	sd	s1,24(sp)
    800025be:	e84a                	sd	s2,16(sp)
    800025c0:	e44e                	sd	s3,8(sp)
    800025c2:	1800                	addi	s0,sp,48
    800025c4:	892a                	mv	s2,a0
    800025c6:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800025c8:	0010c517          	auipc	a0,0x10c
    800025cc:	31050513          	addi	a0,a0,784 # 8010e8d8 <bcache>
    800025d0:	00004097          	auipc	ra,0x4
    800025d4:	dea080e7          	jalr	-534(ra) # 800063ba <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800025d8:	00114497          	auipc	s1,0x114
    800025dc:	5b84b483          	ld	s1,1464(s1) # 80116b90 <bcache+0x82b8>
    800025e0:	00114797          	auipc	a5,0x114
    800025e4:	56078793          	addi	a5,a5,1376 # 80116b40 <bcache+0x8268>
    800025e8:	02f48f63          	beq	s1,a5,80002626 <bread+0x70>
    800025ec:	873e                	mv	a4,a5
    800025ee:	a021                	j	800025f6 <bread+0x40>
    800025f0:	68a4                	ld	s1,80(s1)
    800025f2:	02e48a63          	beq	s1,a4,80002626 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800025f6:	449c                	lw	a5,8(s1)
    800025f8:	ff279ce3          	bne	a5,s2,800025f0 <bread+0x3a>
    800025fc:	44dc                	lw	a5,12(s1)
    800025fe:	ff3799e3          	bne	a5,s3,800025f0 <bread+0x3a>
      b->refcnt++;
    80002602:	40bc                	lw	a5,64(s1)
    80002604:	2785                	addiw	a5,a5,1
    80002606:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002608:	0010c517          	auipc	a0,0x10c
    8000260c:	2d050513          	addi	a0,a0,720 # 8010e8d8 <bcache>
    80002610:	00004097          	auipc	ra,0x4
    80002614:	e5e080e7          	jalr	-418(ra) # 8000646e <release>
      acquiresleep(&b->lock);
    80002618:	01048513          	addi	a0,s1,16
    8000261c:	00001097          	auipc	ra,0x1
    80002620:	46e080e7          	jalr	1134(ra) # 80003a8a <acquiresleep>
      return b;
    80002624:	a8b9                	j	80002682 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002626:	00114497          	auipc	s1,0x114
    8000262a:	5624b483          	ld	s1,1378(s1) # 80116b88 <bcache+0x82b0>
    8000262e:	00114797          	auipc	a5,0x114
    80002632:	51278793          	addi	a5,a5,1298 # 80116b40 <bcache+0x8268>
    80002636:	00f48863          	beq	s1,a5,80002646 <bread+0x90>
    8000263a:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000263c:	40bc                	lw	a5,64(s1)
    8000263e:	cf81                	beqz	a5,80002656 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002640:	64a4                	ld	s1,72(s1)
    80002642:	fee49de3          	bne	s1,a4,8000263c <bread+0x86>
  panic("bget: no buffers");
    80002646:	00006517          	auipc	a0,0x6
    8000264a:	eb250513          	addi	a0,a0,-334 # 800084f8 <syscalls+0xc0>
    8000264e:	00004097          	auipc	ra,0x4
    80002652:	830080e7          	jalr	-2000(ra) # 80005e7e <panic>
      b->dev = dev;
    80002656:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000265a:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000265e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002662:	4785                	li	a5,1
    80002664:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002666:	0010c517          	auipc	a0,0x10c
    8000266a:	27250513          	addi	a0,a0,626 # 8010e8d8 <bcache>
    8000266e:	00004097          	auipc	ra,0x4
    80002672:	e00080e7          	jalr	-512(ra) # 8000646e <release>
      acquiresleep(&b->lock);
    80002676:	01048513          	addi	a0,s1,16
    8000267a:	00001097          	auipc	ra,0x1
    8000267e:	410080e7          	jalr	1040(ra) # 80003a8a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002682:	409c                	lw	a5,0(s1)
    80002684:	cb89                	beqz	a5,80002696 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002686:	8526                	mv	a0,s1
    80002688:	70a2                	ld	ra,40(sp)
    8000268a:	7402                	ld	s0,32(sp)
    8000268c:	64e2                	ld	s1,24(sp)
    8000268e:	6942                	ld	s2,16(sp)
    80002690:	69a2                	ld	s3,8(sp)
    80002692:	6145                	addi	sp,sp,48
    80002694:	8082                	ret
    virtio_disk_rw(b, 0);
    80002696:	4581                	li	a1,0
    80002698:	8526                	mv	a0,s1
    8000269a:	00003097          	auipc	ra,0x3
    8000269e:	fda080e7          	jalr	-38(ra) # 80005674 <virtio_disk_rw>
    b->valid = 1;
    800026a2:	4785                	li	a5,1
    800026a4:	c09c                	sw	a5,0(s1)
  return b;
    800026a6:	b7c5                	j	80002686 <bread+0xd0>

00000000800026a8 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800026a8:	1101                	addi	sp,sp,-32
    800026aa:	ec06                	sd	ra,24(sp)
    800026ac:	e822                	sd	s0,16(sp)
    800026ae:	e426                	sd	s1,8(sp)
    800026b0:	1000                	addi	s0,sp,32
    800026b2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800026b4:	0541                	addi	a0,a0,16
    800026b6:	00001097          	auipc	ra,0x1
    800026ba:	46e080e7          	jalr	1134(ra) # 80003b24 <holdingsleep>
    800026be:	cd01                	beqz	a0,800026d6 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800026c0:	4585                	li	a1,1
    800026c2:	8526                	mv	a0,s1
    800026c4:	00003097          	auipc	ra,0x3
    800026c8:	fb0080e7          	jalr	-80(ra) # 80005674 <virtio_disk_rw>
}
    800026cc:	60e2                	ld	ra,24(sp)
    800026ce:	6442                	ld	s0,16(sp)
    800026d0:	64a2                	ld	s1,8(sp)
    800026d2:	6105                	addi	sp,sp,32
    800026d4:	8082                	ret
    panic("bwrite");
    800026d6:	00006517          	auipc	a0,0x6
    800026da:	e3a50513          	addi	a0,a0,-454 # 80008510 <syscalls+0xd8>
    800026de:	00003097          	auipc	ra,0x3
    800026e2:	7a0080e7          	jalr	1952(ra) # 80005e7e <panic>

00000000800026e6 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800026e6:	1101                	addi	sp,sp,-32
    800026e8:	ec06                	sd	ra,24(sp)
    800026ea:	e822                	sd	s0,16(sp)
    800026ec:	e426                	sd	s1,8(sp)
    800026ee:	e04a                	sd	s2,0(sp)
    800026f0:	1000                	addi	s0,sp,32
    800026f2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800026f4:	01050913          	addi	s2,a0,16
    800026f8:	854a                	mv	a0,s2
    800026fa:	00001097          	auipc	ra,0x1
    800026fe:	42a080e7          	jalr	1066(ra) # 80003b24 <holdingsleep>
    80002702:	c92d                	beqz	a0,80002774 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80002704:	854a                	mv	a0,s2
    80002706:	00001097          	auipc	ra,0x1
    8000270a:	3da080e7          	jalr	986(ra) # 80003ae0 <releasesleep>

  acquire(&bcache.lock);
    8000270e:	0010c517          	auipc	a0,0x10c
    80002712:	1ca50513          	addi	a0,a0,458 # 8010e8d8 <bcache>
    80002716:	00004097          	auipc	ra,0x4
    8000271a:	ca4080e7          	jalr	-860(ra) # 800063ba <acquire>
  b->refcnt--;
    8000271e:	40bc                	lw	a5,64(s1)
    80002720:	37fd                	addiw	a5,a5,-1
    80002722:	0007871b          	sext.w	a4,a5
    80002726:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002728:	eb05                	bnez	a4,80002758 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000272a:	68bc                	ld	a5,80(s1)
    8000272c:	64b8                	ld	a4,72(s1)
    8000272e:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002730:	64bc                	ld	a5,72(s1)
    80002732:	68b8                	ld	a4,80(s1)
    80002734:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002736:	00114797          	auipc	a5,0x114
    8000273a:	1a278793          	addi	a5,a5,418 # 801168d8 <bcache+0x8000>
    8000273e:	2b87b703          	ld	a4,696(a5)
    80002742:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002744:	00114717          	auipc	a4,0x114
    80002748:	3fc70713          	addi	a4,a4,1020 # 80116b40 <bcache+0x8268>
    8000274c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000274e:	2b87b703          	ld	a4,696(a5)
    80002752:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002754:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002758:	0010c517          	auipc	a0,0x10c
    8000275c:	18050513          	addi	a0,a0,384 # 8010e8d8 <bcache>
    80002760:	00004097          	auipc	ra,0x4
    80002764:	d0e080e7          	jalr	-754(ra) # 8000646e <release>
}
    80002768:	60e2                	ld	ra,24(sp)
    8000276a:	6442                	ld	s0,16(sp)
    8000276c:	64a2                	ld	s1,8(sp)
    8000276e:	6902                	ld	s2,0(sp)
    80002770:	6105                	addi	sp,sp,32
    80002772:	8082                	ret
    panic("brelse");
    80002774:	00006517          	auipc	a0,0x6
    80002778:	da450513          	addi	a0,a0,-604 # 80008518 <syscalls+0xe0>
    8000277c:	00003097          	auipc	ra,0x3
    80002780:	702080e7          	jalr	1794(ra) # 80005e7e <panic>

0000000080002784 <bpin>:

void
bpin(struct buf *b) {
    80002784:	1101                	addi	sp,sp,-32
    80002786:	ec06                	sd	ra,24(sp)
    80002788:	e822                	sd	s0,16(sp)
    8000278a:	e426                	sd	s1,8(sp)
    8000278c:	1000                	addi	s0,sp,32
    8000278e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002790:	0010c517          	auipc	a0,0x10c
    80002794:	14850513          	addi	a0,a0,328 # 8010e8d8 <bcache>
    80002798:	00004097          	auipc	ra,0x4
    8000279c:	c22080e7          	jalr	-990(ra) # 800063ba <acquire>
  b->refcnt++;
    800027a0:	40bc                	lw	a5,64(s1)
    800027a2:	2785                	addiw	a5,a5,1
    800027a4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800027a6:	0010c517          	auipc	a0,0x10c
    800027aa:	13250513          	addi	a0,a0,306 # 8010e8d8 <bcache>
    800027ae:	00004097          	auipc	ra,0x4
    800027b2:	cc0080e7          	jalr	-832(ra) # 8000646e <release>
}
    800027b6:	60e2                	ld	ra,24(sp)
    800027b8:	6442                	ld	s0,16(sp)
    800027ba:	64a2                	ld	s1,8(sp)
    800027bc:	6105                	addi	sp,sp,32
    800027be:	8082                	ret

00000000800027c0 <bunpin>:

void
bunpin(struct buf *b) {
    800027c0:	1101                	addi	sp,sp,-32
    800027c2:	ec06                	sd	ra,24(sp)
    800027c4:	e822                	sd	s0,16(sp)
    800027c6:	e426                	sd	s1,8(sp)
    800027c8:	1000                	addi	s0,sp,32
    800027ca:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800027cc:	0010c517          	auipc	a0,0x10c
    800027d0:	10c50513          	addi	a0,a0,268 # 8010e8d8 <bcache>
    800027d4:	00004097          	auipc	ra,0x4
    800027d8:	be6080e7          	jalr	-1050(ra) # 800063ba <acquire>
  b->refcnt--;
    800027dc:	40bc                	lw	a5,64(s1)
    800027de:	37fd                	addiw	a5,a5,-1
    800027e0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800027e2:	0010c517          	auipc	a0,0x10c
    800027e6:	0f650513          	addi	a0,a0,246 # 8010e8d8 <bcache>
    800027ea:	00004097          	auipc	ra,0x4
    800027ee:	c84080e7          	jalr	-892(ra) # 8000646e <release>
}
    800027f2:	60e2                	ld	ra,24(sp)
    800027f4:	6442                	ld	s0,16(sp)
    800027f6:	64a2                	ld	s1,8(sp)
    800027f8:	6105                	addi	sp,sp,32
    800027fa:	8082                	ret

00000000800027fc <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800027fc:	1101                	addi	sp,sp,-32
    800027fe:	ec06                	sd	ra,24(sp)
    80002800:	e822                	sd	s0,16(sp)
    80002802:	e426                	sd	s1,8(sp)
    80002804:	e04a                	sd	s2,0(sp)
    80002806:	1000                	addi	s0,sp,32
    80002808:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000280a:	00d5d59b          	srliw	a1,a1,0xd
    8000280e:	00114797          	auipc	a5,0x114
    80002812:	7a67a783          	lw	a5,1958(a5) # 80116fb4 <sb+0x1c>
    80002816:	9dbd                	addw	a1,a1,a5
    80002818:	00000097          	auipc	ra,0x0
    8000281c:	d9e080e7          	jalr	-610(ra) # 800025b6 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002820:	0074f713          	andi	a4,s1,7
    80002824:	4785                	li	a5,1
    80002826:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000282a:	14ce                	slli	s1,s1,0x33
    8000282c:	90d9                	srli	s1,s1,0x36
    8000282e:	00950733          	add	a4,a0,s1
    80002832:	05874703          	lbu	a4,88(a4)
    80002836:	00e7f6b3          	and	a3,a5,a4
    8000283a:	c69d                	beqz	a3,80002868 <bfree+0x6c>
    8000283c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000283e:	94aa                	add	s1,s1,a0
    80002840:	fff7c793          	not	a5,a5
    80002844:	8ff9                	and	a5,a5,a4
    80002846:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    8000284a:	00001097          	auipc	ra,0x1
    8000284e:	120080e7          	jalr	288(ra) # 8000396a <log_write>
  brelse(bp);
    80002852:	854a                	mv	a0,s2
    80002854:	00000097          	auipc	ra,0x0
    80002858:	e92080e7          	jalr	-366(ra) # 800026e6 <brelse>
}
    8000285c:	60e2                	ld	ra,24(sp)
    8000285e:	6442                	ld	s0,16(sp)
    80002860:	64a2                	ld	s1,8(sp)
    80002862:	6902                	ld	s2,0(sp)
    80002864:	6105                	addi	sp,sp,32
    80002866:	8082                	ret
    panic("freeing free block");
    80002868:	00006517          	auipc	a0,0x6
    8000286c:	cb850513          	addi	a0,a0,-840 # 80008520 <syscalls+0xe8>
    80002870:	00003097          	auipc	ra,0x3
    80002874:	60e080e7          	jalr	1550(ra) # 80005e7e <panic>

0000000080002878 <balloc>:
{
    80002878:	711d                	addi	sp,sp,-96
    8000287a:	ec86                	sd	ra,88(sp)
    8000287c:	e8a2                	sd	s0,80(sp)
    8000287e:	e4a6                	sd	s1,72(sp)
    80002880:	e0ca                	sd	s2,64(sp)
    80002882:	fc4e                	sd	s3,56(sp)
    80002884:	f852                	sd	s4,48(sp)
    80002886:	f456                	sd	s5,40(sp)
    80002888:	f05a                	sd	s6,32(sp)
    8000288a:	ec5e                	sd	s7,24(sp)
    8000288c:	e862                	sd	s8,16(sp)
    8000288e:	e466                	sd	s9,8(sp)
    80002890:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002892:	00114797          	auipc	a5,0x114
    80002896:	70a7a783          	lw	a5,1802(a5) # 80116f9c <sb+0x4>
    8000289a:	10078163          	beqz	a5,8000299c <balloc+0x124>
    8000289e:	8baa                	mv	s7,a0
    800028a0:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800028a2:	00114b17          	auipc	s6,0x114
    800028a6:	6f6b0b13          	addi	s6,s6,1782 # 80116f98 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800028aa:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800028ac:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800028ae:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800028b0:	6c89                	lui	s9,0x2
    800028b2:	a061                	j	8000293a <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    800028b4:	974a                	add	a4,a4,s2
    800028b6:	8fd5                	or	a5,a5,a3
    800028b8:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800028bc:	854a                	mv	a0,s2
    800028be:	00001097          	auipc	ra,0x1
    800028c2:	0ac080e7          	jalr	172(ra) # 8000396a <log_write>
        brelse(bp);
    800028c6:	854a                	mv	a0,s2
    800028c8:	00000097          	auipc	ra,0x0
    800028cc:	e1e080e7          	jalr	-482(ra) # 800026e6 <brelse>
  bp = bread(dev, bno);
    800028d0:	85a6                	mv	a1,s1
    800028d2:	855e                	mv	a0,s7
    800028d4:	00000097          	auipc	ra,0x0
    800028d8:	ce2080e7          	jalr	-798(ra) # 800025b6 <bread>
    800028dc:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800028de:	40000613          	li	a2,1024
    800028e2:	4581                	li	a1,0
    800028e4:	05850513          	addi	a0,a0,88
    800028e8:	ffffe097          	auipc	ra,0xffffe
    800028ec:	9de080e7          	jalr	-1570(ra) # 800002c6 <memset>
  log_write(bp);
    800028f0:	854a                	mv	a0,s2
    800028f2:	00001097          	auipc	ra,0x1
    800028f6:	078080e7          	jalr	120(ra) # 8000396a <log_write>
  brelse(bp);
    800028fa:	854a                	mv	a0,s2
    800028fc:	00000097          	auipc	ra,0x0
    80002900:	dea080e7          	jalr	-534(ra) # 800026e6 <brelse>
}
    80002904:	8526                	mv	a0,s1
    80002906:	60e6                	ld	ra,88(sp)
    80002908:	6446                	ld	s0,80(sp)
    8000290a:	64a6                	ld	s1,72(sp)
    8000290c:	6906                	ld	s2,64(sp)
    8000290e:	79e2                	ld	s3,56(sp)
    80002910:	7a42                	ld	s4,48(sp)
    80002912:	7aa2                	ld	s5,40(sp)
    80002914:	7b02                	ld	s6,32(sp)
    80002916:	6be2                	ld	s7,24(sp)
    80002918:	6c42                	ld	s8,16(sp)
    8000291a:	6ca2                	ld	s9,8(sp)
    8000291c:	6125                	addi	sp,sp,96
    8000291e:	8082                	ret
    brelse(bp);
    80002920:	854a                	mv	a0,s2
    80002922:	00000097          	auipc	ra,0x0
    80002926:	dc4080e7          	jalr	-572(ra) # 800026e6 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000292a:	015c87bb          	addw	a5,s9,s5
    8000292e:	00078a9b          	sext.w	s5,a5
    80002932:	004b2703          	lw	a4,4(s6)
    80002936:	06eaf363          	bgeu	s5,a4,8000299c <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    8000293a:	41fad79b          	sraiw	a5,s5,0x1f
    8000293e:	0137d79b          	srliw	a5,a5,0x13
    80002942:	015787bb          	addw	a5,a5,s5
    80002946:	40d7d79b          	sraiw	a5,a5,0xd
    8000294a:	01cb2583          	lw	a1,28(s6)
    8000294e:	9dbd                	addw	a1,a1,a5
    80002950:	855e                	mv	a0,s7
    80002952:	00000097          	auipc	ra,0x0
    80002956:	c64080e7          	jalr	-924(ra) # 800025b6 <bread>
    8000295a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000295c:	004b2503          	lw	a0,4(s6)
    80002960:	000a849b          	sext.w	s1,s5
    80002964:	8662                	mv	a2,s8
    80002966:	faa4fde3          	bgeu	s1,a0,80002920 <balloc+0xa8>
      m = 1 << (bi % 8);
    8000296a:	41f6579b          	sraiw	a5,a2,0x1f
    8000296e:	01d7d69b          	srliw	a3,a5,0x1d
    80002972:	00c6873b          	addw	a4,a3,a2
    80002976:	00777793          	andi	a5,a4,7
    8000297a:	9f95                	subw	a5,a5,a3
    8000297c:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002980:	4037571b          	sraiw	a4,a4,0x3
    80002984:	00e906b3          	add	a3,s2,a4
    80002988:	0586c683          	lbu	a3,88(a3)
    8000298c:	00d7f5b3          	and	a1,a5,a3
    80002990:	d195                	beqz	a1,800028b4 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002992:	2605                	addiw	a2,a2,1
    80002994:	2485                	addiw	s1,s1,1
    80002996:	fd4618e3          	bne	a2,s4,80002966 <balloc+0xee>
    8000299a:	b759                	j	80002920 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    8000299c:	00006517          	auipc	a0,0x6
    800029a0:	b9c50513          	addi	a0,a0,-1124 # 80008538 <syscalls+0x100>
    800029a4:	00003097          	auipc	ra,0x3
    800029a8:	524080e7          	jalr	1316(ra) # 80005ec8 <printf>
  return 0;
    800029ac:	4481                	li	s1,0
    800029ae:	bf99                	j	80002904 <balloc+0x8c>

00000000800029b0 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800029b0:	7179                	addi	sp,sp,-48
    800029b2:	f406                	sd	ra,40(sp)
    800029b4:	f022                	sd	s0,32(sp)
    800029b6:	ec26                	sd	s1,24(sp)
    800029b8:	e84a                	sd	s2,16(sp)
    800029ba:	e44e                	sd	s3,8(sp)
    800029bc:	e052                	sd	s4,0(sp)
    800029be:	1800                	addi	s0,sp,48
    800029c0:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800029c2:	47ad                	li	a5,11
    800029c4:	02b7e763          	bltu	a5,a1,800029f2 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    800029c8:	02059493          	slli	s1,a1,0x20
    800029cc:	9081                	srli	s1,s1,0x20
    800029ce:	048a                	slli	s1,s1,0x2
    800029d0:	94aa                	add	s1,s1,a0
    800029d2:	0504a903          	lw	s2,80(s1)
    800029d6:	06091e63          	bnez	s2,80002a52 <bmap+0xa2>
      addr = balloc(ip->dev);
    800029da:	4108                	lw	a0,0(a0)
    800029dc:	00000097          	auipc	ra,0x0
    800029e0:	e9c080e7          	jalr	-356(ra) # 80002878 <balloc>
    800029e4:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800029e8:	06090563          	beqz	s2,80002a52 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    800029ec:	0524a823          	sw	s2,80(s1)
    800029f0:	a08d                	j	80002a52 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    800029f2:	ff45849b          	addiw	s1,a1,-12
    800029f6:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800029fa:	0ff00793          	li	a5,255
    800029fe:	08e7e563          	bltu	a5,a4,80002a88 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002a02:	08052903          	lw	s2,128(a0)
    80002a06:	00091d63          	bnez	s2,80002a20 <bmap+0x70>
      addr = balloc(ip->dev);
    80002a0a:	4108                	lw	a0,0(a0)
    80002a0c:	00000097          	auipc	ra,0x0
    80002a10:	e6c080e7          	jalr	-404(ra) # 80002878 <balloc>
    80002a14:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002a18:	02090d63          	beqz	s2,80002a52 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002a1c:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80002a20:	85ca                	mv	a1,s2
    80002a22:	0009a503          	lw	a0,0(s3)
    80002a26:	00000097          	auipc	ra,0x0
    80002a2a:	b90080e7          	jalr	-1136(ra) # 800025b6 <bread>
    80002a2e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002a30:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002a34:	02049593          	slli	a1,s1,0x20
    80002a38:	9181                	srli	a1,a1,0x20
    80002a3a:	058a                	slli	a1,a1,0x2
    80002a3c:	00b784b3          	add	s1,a5,a1
    80002a40:	0004a903          	lw	s2,0(s1)
    80002a44:	02090063          	beqz	s2,80002a64 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002a48:	8552                	mv	a0,s4
    80002a4a:	00000097          	auipc	ra,0x0
    80002a4e:	c9c080e7          	jalr	-868(ra) # 800026e6 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80002a52:	854a                	mv	a0,s2
    80002a54:	70a2                	ld	ra,40(sp)
    80002a56:	7402                	ld	s0,32(sp)
    80002a58:	64e2                	ld	s1,24(sp)
    80002a5a:	6942                	ld	s2,16(sp)
    80002a5c:	69a2                	ld	s3,8(sp)
    80002a5e:	6a02                	ld	s4,0(sp)
    80002a60:	6145                	addi	sp,sp,48
    80002a62:	8082                	ret
      addr = balloc(ip->dev);
    80002a64:	0009a503          	lw	a0,0(s3)
    80002a68:	00000097          	auipc	ra,0x0
    80002a6c:	e10080e7          	jalr	-496(ra) # 80002878 <balloc>
    80002a70:	0005091b          	sext.w	s2,a0
      if(addr){
    80002a74:	fc090ae3          	beqz	s2,80002a48 <bmap+0x98>
        a[bn] = addr;
    80002a78:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002a7c:	8552                	mv	a0,s4
    80002a7e:	00001097          	auipc	ra,0x1
    80002a82:	eec080e7          	jalr	-276(ra) # 8000396a <log_write>
    80002a86:	b7c9                	j	80002a48 <bmap+0x98>
  panic("bmap: out of range");
    80002a88:	00006517          	auipc	a0,0x6
    80002a8c:	ac850513          	addi	a0,a0,-1336 # 80008550 <syscalls+0x118>
    80002a90:	00003097          	auipc	ra,0x3
    80002a94:	3ee080e7          	jalr	1006(ra) # 80005e7e <panic>

0000000080002a98 <iget>:
{
    80002a98:	7179                	addi	sp,sp,-48
    80002a9a:	f406                	sd	ra,40(sp)
    80002a9c:	f022                	sd	s0,32(sp)
    80002a9e:	ec26                	sd	s1,24(sp)
    80002aa0:	e84a                	sd	s2,16(sp)
    80002aa2:	e44e                	sd	s3,8(sp)
    80002aa4:	e052                	sd	s4,0(sp)
    80002aa6:	1800                	addi	s0,sp,48
    80002aa8:	89aa                	mv	s3,a0
    80002aaa:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002aac:	00114517          	auipc	a0,0x114
    80002ab0:	50c50513          	addi	a0,a0,1292 # 80116fb8 <itable>
    80002ab4:	00004097          	auipc	ra,0x4
    80002ab8:	906080e7          	jalr	-1786(ra) # 800063ba <acquire>
  empty = 0;
    80002abc:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002abe:	00114497          	auipc	s1,0x114
    80002ac2:	51248493          	addi	s1,s1,1298 # 80116fd0 <itable+0x18>
    80002ac6:	00116697          	auipc	a3,0x116
    80002aca:	f9a68693          	addi	a3,a3,-102 # 80118a60 <log>
    80002ace:	a039                	j	80002adc <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002ad0:	02090b63          	beqz	s2,80002b06 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002ad4:	08848493          	addi	s1,s1,136
    80002ad8:	02d48a63          	beq	s1,a3,80002b0c <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002adc:	449c                	lw	a5,8(s1)
    80002ade:	fef059e3          	blez	a5,80002ad0 <iget+0x38>
    80002ae2:	4098                	lw	a4,0(s1)
    80002ae4:	ff3716e3          	bne	a4,s3,80002ad0 <iget+0x38>
    80002ae8:	40d8                	lw	a4,4(s1)
    80002aea:	ff4713e3          	bne	a4,s4,80002ad0 <iget+0x38>
      ip->ref++;
    80002aee:	2785                	addiw	a5,a5,1
    80002af0:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002af2:	00114517          	auipc	a0,0x114
    80002af6:	4c650513          	addi	a0,a0,1222 # 80116fb8 <itable>
    80002afa:	00004097          	auipc	ra,0x4
    80002afe:	974080e7          	jalr	-1676(ra) # 8000646e <release>
      return ip;
    80002b02:	8926                	mv	s2,s1
    80002b04:	a03d                	j	80002b32 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002b06:	f7f9                	bnez	a5,80002ad4 <iget+0x3c>
    80002b08:	8926                	mv	s2,s1
    80002b0a:	b7e9                	j	80002ad4 <iget+0x3c>
  if(empty == 0)
    80002b0c:	02090c63          	beqz	s2,80002b44 <iget+0xac>
  ip->dev = dev;
    80002b10:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002b14:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80002b18:	4785                	li	a5,1
    80002b1a:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002b1e:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80002b22:	00114517          	auipc	a0,0x114
    80002b26:	49650513          	addi	a0,a0,1174 # 80116fb8 <itable>
    80002b2a:	00004097          	auipc	ra,0x4
    80002b2e:	944080e7          	jalr	-1724(ra) # 8000646e <release>
}
    80002b32:	854a                	mv	a0,s2
    80002b34:	70a2                	ld	ra,40(sp)
    80002b36:	7402                	ld	s0,32(sp)
    80002b38:	64e2                	ld	s1,24(sp)
    80002b3a:	6942                	ld	s2,16(sp)
    80002b3c:	69a2                	ld	s3,8(sp)
    80002b3e:	6a02                	ld	s4,0(sp)
    80002b40:	6145                	addi	sp,sp,48
    80002b42:	8082                	ret
    panic("iget: no inodes");
    80002b44:	00006517          	auipc	a0,0x6
    80002b48:	a2450513          	addi	a0,a0,-1500 # 80008568 <syscalls+0x130>
    80002b4c:	00003097          	auipc	ra,0x3
    80002b50:	332080e7          	jalr	818(ra) # 80005e7e <panic>

0000000080002b54 <fsinit>:
fsinit(int dev) {
    80002b54:	7179                	addi	sp,sp,-48
    80002b56:	f406                	sd	ra,40(sp)
    80002b58:	f022                	sd	s0,32(sp)
    80002b5a:	ec26                	sd	s1,24(sp)
    80002b5c:	e84a                	sd	s2,16(sp)
    80002b5e:	e44e                	sd	s3,8(sp)
    80002b60:	1800                	addi	s0,sp,48
    80002b62:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80002b64:	4585                	li	a1,1
    80002b66:	00000097          	auipc	ra,0x0
    80002b6a:	a50080e7          	jalr	-1456(ra) # 800025b6 <bread>
    80002b6e:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80002b70:	00114997          	auipc	s3,0x114
    80002b74:	42898993          	addi	s3,s3,1064 # 80116f98 <sb>
    80002b78:	02000613          	li	a2,32
    80002b7c:	05850593          	addi	a1,a0,88
    80002b80:	854e                	mv	a0,s3
    80002b82:	ffffd097          	auipc	ra,0xffffd
    80002b86:	7a0080e7          	jalr	1952(ra) # 80000322 <memmove>
  brelse(bp);
    80002b8a:	8526                	mv	a0,s1
    80002b8c:	00000097          	auipc	ra,0x0
    80002b90:	b5a080e7          	jalr	-1190(ra) # 800026e6 <brelse>
  if(sb.magic != FSMAGIC)
    80002b94:	0009a703          	lw	a4,0(s3)
    80002b98:	102037b7          	lui	a5,0x10203
    80002b9c:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80002ba0:	02f71263          	bne	a4,a5,80002bc4 <fsinit+0x70>
  initlog(dev, &sb);
    80002ba4:	00114597          	auipc	a1,0x114
    80002ba8:	3f458593          	addi	a1,a1,1012 # 80116f98 <sb>
    80002bac:	854a                	mv	a0,s2
    80002bae:	00001097          	auipc	ra,0x1
    80002bb2:	b40080e7          	jalr	-1216(ra) # 800036ee <initlog>
}
    80002bb6:	70a2                	ld	ra,40(sp)
    80002bb8:	7402                	ld	s0,32(sp)
    80002bba:	64e2                	ld	s1,24(sp)
    80002bbc:	6942                	ld	s2,16(sp)
    80002bbe:	69a2                	ld	s3,8(sp)
    80002bc0:	6145                	addi	sp,sp,48
    80002bc2:	8082                	ret
    panic("invalid file system");
    80002bc4:	00006517          	auipc	a0,0x6
    80002bc8:	9b450513          	addi	a0,a0,-1612 # 80008578 <syscalls+0x140>
    80002bcc:	00003097          	auipc	ra,0x3
    80002bd0:	2b2080e7          	jalr	690(ra) # 80005e7e <panic>

0000000080002bd4 <iinit>:
{
    80002bd4:	7179                	addi	sp,sp,-48
    80002bd6:	f406                	sd	ra,40(sp)
    80002bd8:	f022                	sd	s0,32(sp)
    80002bda:	ec26                	sd	s1,24(sp)
    80002bdc:	e84a                	sd	s2,16(sp)
    80002bde:	e44e                	sd	s3,8(sp)
    80002be0:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80002be2:	00006597          	auipc	a1,0x6
    80002be6:	9ae58593          	addi	a1,a1,-1618 # 80008590 <syscalls+0x158>
    80002bea:	00114517          	auipc	a0,0x114
    80002bee:	3ce50513          	addi	a0,a0,974 # 80116fb8 <itable>
    80002bf2:	00003097          	auipc	ra,0x3
    80002bf6:	738080e7          	jalr	1848(ra) # 8000632a <initlock>
  for(i = 0; i < NINODE; i++) {
    80002bfa:	00114497          	auipc	s1,0x114
    80002bfe:	3e648493          	addi	s1,s1,998 # 80116fe0 <itable+0x28>
    80002c02:	00116997          	auipc	s3,0x116
    80002c06:	e6e98993          	addi	s3,s3,-402 # 80118a70 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80002c0a:	00006917          	auipc	s2,0x6
    80002c0e:	98e90913          	addi	s2,s2,-1650 # 80008598 <syscalls+0x160>
    80002c12:	85ca                	mv	a1,s2
    80002c14:	8526                	mv	a0,s1
    80002c16:	00001097          	auipc	ra,0x1
    80002c1a:	e3a080e7          	jalr	-454(ra) # 80003a50 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80002c1e:	08848493          	addi	s1,s1,136
    80002c22:	ff3498e3          	bne	s1,s3,80002c12 <iinit+0x3e>
}
    80002c26:	70a2                	ld	ra,40(sp)
    80002c28:	7402                	ld	s0,32(sp)
    80002c2a:	64e2                	ld	s1,24(sp)
    80002c2c:	6942                	ld	s2,16(sp)
    80002c2e:	69a2                	ld	s3,8(sp)
    80002c30:	6145                	addi	sp,sp,48
    80002c32:	8082                	ret

0000000080002c34 <ialloc>:
{
    80002c34:	715d                	addi	sp,sp,-80
    80002c36:	e486                	sd	ra,72(sp)
    80002c38:	e0a2                	sd	s0,64(sp)
    80002c3a:	fc26                	sd	s1,56(sp)
    80002c3c:	f84a                	sd	s2,48(sp)
    80002c3e:	f44e                	sd	s3,40(sp)
    80002c40:	f052                	sd	s4,32(sp)
    80002c42:	ec56                	sd	s5,24(sp)
    80002c44:	e85a                	sd	s6,16(sp)
    80002c46:	e45e                	sd	s7,8(sp)
    80002c48:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80002c4a:	00114717          	auipc	a4,0x114
    80002c4e:	35a72703          	lw	a4,858(a4) # 80116fa4 <sb+0xc>
    80002c52:	4785                	li	a5,1
    80002c54:	04e7fa63          	bgeu	a5,a4,80002ca8 <ialloc+0x74>
    80002c58:	8aaa                	mv	s5,a0
    80002c5a:	8bae                	mv	s7,a1
    80002c5c:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80002c5e:	00114a17          	auipc	s4,0x114
    80002c62:	33aa0a13          	addi	s4,s4,826 # 80116f98 <sb>
    80002c66:	00048b1b          	sext.w	s6,s1
    80002c6a:	0044d793          	srli	a5,s1,0x4
    80002c6e:	018a2583          	lw	a1,24(s4)
    80002c72:	9dbd                	addw	a1,a1,a5
    80002c74:	8556                	mv	a0,s5
    80002c76:	00000097          	auipc	ra,0x0
    80002c7a:	940080e7          	jalr	-1728(ra) # 800025b6 <bread>
    80002c7e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80002c80:	05850993          	addi	s3,a0,88
    80002c84:	00f4f793          	andi	a5,s1,15
    80002c88:	079a                	slli	a5,a5,0x6
    80002c8a:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80002c8c:	00099783          	lh	a5,0(s3)
    80002c90:	c3a1                	beqz	a5,80002cd0 <ialloc+0x9c>
    brelse(bp);
    80002c92:	00000097          	auipc	ra,0x0
    80002c96:	a54080e7          	jalr	-1452(ra) # 800026e6 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80002c9a:	0485                	addi	s1,s1,1
    80002c9c:	00ca2703          	lw	a4,12(s4)
    80002ca0:	0004879b          	sext.w	a5,s1
    80002ca4:	fce7e1e3          	bltu	a5,a4,80002c66 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80002ca8:	00006517          	auipc	a0,0x6
    80002cac:	8f850513          	addi	a0,a0,-1800 # 800085a0 <syscalls+0x168>
    80002cb0:	00003097          	auipc	ra,0x3
    80002cb4:	218080e7          	jalr	536(ra) # 80005ec8 <printf>
  return 0;
    80002cb8:	4501                	li	a0,0
}
    80002cba:	60a6                	ld	ra,72(sp)
    80002cbc:	6406                	ld	s0,64(sp)
    80002cbe:	74e2                	ld	s1,56(sp)
    80002cc0:	7942                	ld	s2,48(sp)
    80002cc2:	79a2                	ld	s3,40(sp)
    80002cc4:	7a02                	ld	s4,32(sp)
    80002cc6:	6ae2                	ld	s5,24(sp)
    80002cc8:	6b42                	ld	s6,16(sp)
    80002cca:	6ba2                	ld	s7,8(sp)
    80002ccc:	6161                	addi	sp,sp,80
    80002cce:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80002cd0:	04000613          	li	a2,64
    80002cd4:	4581                	li	a1,0
    80002cd6:	854e                	mv	a0,s3
    80002cd8:	ffffd097          	auipc	ra,0xffffd
    80002cdc:	5ee080e7          	jalr	1518(ra) # 800002c6 <memset>
      dip->type = type;
    80002ce0:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80002ce4:	854a                	mv	a0,s2
    80002ce6:	00001097          	auipc	ra,0x1
    80002cea:	c84080e7          	jalr	-892(ra) # 8000396a <log_write>
      brelse(bp);
    80002cee:	854a                	mv	a0,s2
    80002cf0:	00000097          	auipc	ra,0x0
    80002cf4:	9f6080e7          	jalr	-1546(ra) # 800026e6 <brelse>
      return iget(dev, inum);
    80002cf8:	85da                	mv	a1,s6
    80002cfa:	8556                	mv	a0,s5
    80002cfc:	00000097          	auipc	ra,0x0
    80002d00:	d9c080e7          	jalr	-612(ra) # 80002a98 <iget>
    80002d04:	bf5d                	j	80002cba <ialloc+0x86>

0000000080002d06 <iupdate>:
{
    80002d06:	1101                	addi	sp,sp,-32
    80002d08:	ec06                	sd	ra,24(sp)
    80002d0a:	e822                	sd	s0,16(sp)
    80002d0c:	e426                	sd	s1,8(sp)
    80002d0e:	e04a                	sd	s2,0(sp)
    80002d10:	1000                	addi	s0,sp,32
    80002d12:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002d14:	415c                	lw	a5,4(a0)
    80002d16:	0047d79b          	srliw	a5,a5,0x4
    80002d1a:	00114597          	auipc	a1,0x114
    80002d1e:	2965a583          	lw	a1,662(a1) # 80116fb0 <sb+0x18>
    80002d22:	9dbd                	addw	a1,a1,a5
    80002d24:	4108                	lw	a0,0(a0)
    80002d26:	00000097          	auipc	ra,0x0
    80002d2a:	890080e7          	jalr	-1904(ra) # 800025b6 <bread>
    80002d2e:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002d30:	05850793          	addi	a5,a0,88
    80002d34:	40c8                	lw	a0,4(s1)
    80002d36:	893d                	andi	a0,a0,15
    80002d38:	051a                	slli	a0,a0,0x6
    80002d3a:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80002d3c:	04449703          	lh	a4,68(s1)
    80002d40:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80002d44:	04649703          	lh	a4,70(s1)
    80002d48:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80002d4c:	04849703          	lh	a4,72(s1)
    80002d50:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80002d54:	04a49703          	lh	a4,74(s1)
    80002d58:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80002d5c:	44f8                	lw	a4,76(s1)
    80002d5e:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80002d60:	03400613          	li	a2,52
    80002d64:	05048593          	addi	a1,s1,80
    80002d68:	0531                	addi	a0,a0,12
    80002d6a:	ffffd097          	auipc	ra,0xffffd
    80002d6e:	5b8080e7          	jalr	1464(ra) # 80000322 <memmove>
  log_write(bp);
    80002d72:	854a                	mv	a0,s2
    80002d74:	00001097          	auipc	ra,0x1
    80002d78:	bf6080e7          	jalr	-1034(ra) # 8000396a <log_write>
  brelse(bp);
    80002d7c:	854a                	mv	a0,s2
    80002d7e:	00000097          	auipc	ra,0x0
    80002d82:	968080e7          	jalr	-1688(ra) # 800026e6 <brelse>
}
    80002d86:	60e2                	ld	ra,24(sp)
    80002d88:	6442                	ld	s0,16(sp)
    80002d8a:	64a2                	ld	s1,8(sp)
    80002d8c:	6902                	ld	s2,0(sp)
    80002d8e:	6105                	addi	sp,sp,32
    80002d90:	8082                	ret

0000000080002d92 <idup>:
{
    80002d92:	1101                	addi	sp,sp,-32
    80002d94:	ec06                	sd	ra,24(sp)
    80002d96:	e822                	sd	s0,16(sp)
    80002d98:	e426                	sd	s1,8(sp)
    80002d9a:	1000                	addi	s0,sp,32
    80002d9c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002d9e:	00114517          	auipc	a0,0x114
    80002da2:	21a50513          	addi	a0,a0,538 # 80116fb8 <itable>
    80002da6:	00003097          	auipc	ra,0x3
    80002daa:	614080e7          	jalr	1556(ra) # 800063ba <acquire>
  ip->ref++;
    80002dae:	449c                	lw	a5,8(s1)
    80002db0:	2785                	addiw	a5,a5,1
    80002db2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002db4:	00114517          	auipc	a0,0x114
    80002db8:	20450513          	addi	a0,a0,516 # 80116fb8 <itable>
    80002dbc:	00003097          	auipc	ra,0x3
    80002dc0:	6b2080e7          	jalr	1714(ra) # 8000646e <release>
}
    80002dc4:	8526                	mv	a0,s1
    80002dc6:	60e2                	ld	ra,24(sp)
    80002dc8:	6442                	ld	s0,16(sp)
    80002dca:	64a2                	ld	s1,8(sp)
    80002dcc:	6105                	addi	sp,sp,32
    80002dce:	8082                	ret

0000000080002dd0 <ilock>:
{
    80002dd0:	1101                	addi	sp,sp,-32
    80002dd2:	ec06                	sd	ra,24(sp)
    80002dd4:	e822                	sd	s0,16(sp)
    80002dd6:	e426                	sd	s1,8(sp)
    80002dd8:	e04a                	sd	s2,0(sp)
    80002dda:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80002ddc:	c115                	beqz	a0,80002e00 <ilock+0x30>
    80002dde:	84aa                	mv	s1,a0
    80002de0:	451c                	lw	a5,8(a0)
    80002de2:	00f05f63          	blez	a5,80002e00 <ilock+0x30>
  acquiresleep(&ip->lock);
    80002de6:	0541                	addi	a0,a0,16
    80002de8:	00001097          	auipc	ra,0x1
    80002dec:	ca2080e7          	jalr	-862(ra) # 80003a8a <acquiresleep>
  if(ip->valid == 0){
    80002df0:	40bc                	lw	a5,64(s1)
    80002df2:	cf99                	beqz	a5,80002e10 <ilock+0x40>
}
    80002df4:	60e2                	ld	ra,24(sp)
    80002df6:	6442                	ld	s0,16(sp)
    80002df8:	64a2                	ld	s1,8(sp)
    80002dfa:	6902                	ld	s2,0(sp)
    80002dfc:	6105                	addi	sp,sp,32
    80002dfe:	8082                	ret
    panic("ilock");
    80002e00:	00005517          	auipc	a0,0x5
    80002e04:	7b850513          	addi	a0,a0,1976 # 800085b8 <syscalls+0x180>
    80002e08:	00003097          	auipc	ra,0x3
    80002e0c:	076080e7          	jalr	118(ra) # 80005e7e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002e10:	40dc                	lw	a5,4(s1)
    80002e12:	0047d79b          	srliw	a5,a5,0x4
    80002e16:	00114597          	auipc	a1,0x114
    80002e1a:	19a5a583          	lw	a1,410(a1) # 80116fb0 <sb+0x18>
    80002e1e:	9dbd                	addw	a1,a1,a5
    80002e20:	4088                	lw	a0,0(s1)
    80002e22:	fffff097          	auipc	ra,0xfffff
    80002e26:	794080e7          	jalr	1940(ra) # 800025b6 <bread>
    80002e2a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002e2c:	05850593          	addi	a1,a0,88
    80002e30:	40dc                	lw	a5,4(s1)
    80002e32:	8bbd                	andi	a5,a5,15
    80002e34:	079a                	slli	a5,a5,0x6
    80002e36:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80002e38:	00059783          	lh	a5,0(a1)
    80002e3c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80002e40:	00259783          	lh	a5,2(a1)
    80002e44:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80002e48:	00459783          	lh	a5,4(a1)
    80002e4c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80002e50:	00659783          	lh	a5,6(a1)
    80002e54:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80002e58:	459c                	lw	a5,8(a1)
    80002e5a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80002e5c:	03400613          	li	a2,52
    80002e60:	05b1                	addi	a1,a1,12
    80002e62:	05048513          	addi	a0,s1,80
    80002e66:	ffffd097          	auipc	ra,0xffffd
    80002e6a:	4bc080e7          	jalr	1212(ra) # 80000322 <memmove>
    brelse(bp);
    80002e6e:	854a                	mv	a0,s2
    80002e70:	00000097          	auipc	ra,0x0
    80002e74:	876080e7          	jalr	-1930(ra) # 800026e6 <brelse>
    ip->valid = 1;
    80002e78:	4785                	li	a5,1
    80002e7a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80002e7c:	04449783          	lh	a5,68(s1)
    80002e80:	fbb5                	bnez	a5,80002df4 <ilock+0x24>
      panic("ilock: no type");
    80002e82:	00005517          	auipc	a0,0x5
    80002e86:	73e50513          	addi	a0,a0,1854 # 800085c0 <syscalls+0x188>
    80002e8a:	00003097          	auipc	ra,0x3
    80002e8e:	ff4080e7          	jalr	-12(ra) # 80005e7e <panic>

0000000080002e92 <iunlock>:
{
    80002e92:	1101                	addi	sp,sp,-32
    80002e94:	ec06                	sd	ra,24(sp)
    80002e96:	e822                	sd	s0,16(sp)
    80002e98:	e426                	sd	s1,8(sp)
    80002e9a:	e04a                	sd	s2,0(sp)
    80002e9c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80002e9e:	c905                	beqz	a0,80002ece <iunlock+0x3c>
    80002ea0:	84aa                	mv	s1,a0
    80002ea2:	01050913          	addi	s2,a0,16
    80002ea6:	854a                	mv	a0,s2
    80002ea8:	00001097          	auipc	ra,0x1
    80002eac:	c7c080e7          	jalr	-900(ra) # 80003b24 <holdingsleep>
    80002eb0:	cd19                	beqz	a0,80002ece <iunlock+0x3c>
    80002eb2:	449c                	lw	a5,8(s1)
    80002eb4:	00f05d63          	blez	a5,80002ece <iunlock+0x3c>
  releasesleep(&ip->lock);
    80002eb8:	854a                	mv	a0,s2
    80002eba:	00001097          	auipc	ra,0x1
    80002ebe:	c26080e7          	jalr	-986(ra) # 80003ae0 <releasesleep>
}
    80002ec2:	60e2                	ld	ra,24(sp)
    80002ec4:	6442                	ld	s0,16(sp)
    80002ec6:	64a2                	ld	s1,8(sp)
    80002ec8:	6902                	ld	s2,0(sp)
    80002eca:	6105                	addi	sp,sp,32
    80002ecc:	8082                	ret
    panic("iunlock");
    80002ece:	00005517          	auipc	a0,0x5
    80002ed2:	70250513          	addi	a0,a0,1794 # 800085d0 <syscalls+0x198>
    80002ed6:	00003097          	auipc	ra,0x3
    80002eda:	fa8080e7          	jalr	-88(ra) # 80005e7e <panic>

0000000080002ede <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80002ede:	7179                	addi	sp,sp,-48
    80002ee0:	f406                	sd	ra,40(sp)
    80002ee2:	f022                	sd	s0,32(sp)
    80002ee4:	ec26                	sd	s1,24(sp)
    80002ee6:	e84a                	sd	s2,16(sp)
    80002ee8:	e44e                	sd	s3,8(sp)
    80002eea:	e052                	sd	s4,0(sp)
    80002eec:	1800                	addi	s0,sp,48
    80002eee:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80002ef0:	05050493          	addi	s1,a0,80
    80002ef4:	08050913          	addi	s2,a0,128
    80002ef8:	a021                	j	80002f00 <itrunc+0x22>
    80002efa:	0491                	addi	s1,s1,4
    80002efc:	01248d63          	beq	s1,s2,80002f16 <itrunc+0x38>
    if(ip->addrs[i]){
    80002f00:	408c                	lw	a1,0(s1)
    80002f02:	dde5                	beqz	a1,80002efa <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80002f04:	0009a503          	lw	a0,0(s3)
    80002f08:	00000097          	auipc	ra,0x0
    80002f0c:	8f4080e7          	jalr	-1804(ra) # 800027fc <bfree>
      ip->addrs[i] = 0;
    80002f10:	0004a023          	sw	zero,0(s1)
    80002f14:	b7dd                	j	80002efa <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80002f16:	0809a583          	lw	a1,128(s3)
    80002f1a:	e185                	bnez	a1,80002f3a <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80002f1c:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80002f20:	854e                	mv	a0,s3
    80002f22:	00000097          	auipc	ra,0x0
    80002f26:	de4080e7          	jalr	-540(ra) # 80002d06 <iupdate>
}
    80002f2a:	70a2                	ld	ra,40(sp)
    80002f2c:	7402                	ld	s0,32(sp)
    80002f2e:	64e2                	ld	s1,24(sp)
    80002f30:	6942                	ld	s2,16(sp)
    80002f32:	69a2                	ld	s3,8(sp)
    80002f34:	6a02                	ld	s4,0(sp)
    80002f36:	6145                	addi	sp,sp,48
    80002f38:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80002f3a:	0009a503          	lw	a0,0(s3)
    80002f3e:	fffff097          	auipc	ra,0xfffff
    80002f42:	678080e7          	jalr	1656(ra) # 800025b6 <bread>
    80002f46:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80002f48:	05850493          	addi	s1,a0,88
    80002f4c:	45850913          	addi	s2,a0,1112
    80002f50:	a021                	j	80002f58 <itrunc+0x7a>
    80002f52:	0491                	addi	s1,s1,4
    80002f54:	01248b63          	beq	s1,s2,80002f6a <itrunc+0x8c>
      if(a[j])
    80002f58:	408c                	lw	a1,0(s1)
    80002f5a:	dde5                	beqz	a1,80002f52 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80002f5c:	0009a503          	lw	a0,0(s3)
    80002f60:	00000097          	auipc	ra,0x0
    80002f64:	89c080e7          	jalr	-1892(ra) # 800027fc <bfree>
    80002f68:	b7ed                	j	80002f52 <itrunc+0x74>
    brelse(bp);
    80002f6a:	8552                	mv	a0,s4
    80002f6c:	fffff097          	auipc	ra,0xfffff
    80002f70:	77a080e7          	jalr	1914(ra) # 800026e6 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80002f74:	0809a583          	lw	a1,128(s3)
    80002f78:	0009a503          	lw	a0,0(s3)
    80002f7c:	00000097          	auipc	ra,0x0
    80002f80:	880080e7          	jalr	-1920(ra) # 800027fc <bfree>
    ip->addrs[NDIRECT] = 0;
    80002f84:	0809a023          	sw	zero,128(s3)
    80002f88:	bf51                	j	80002f1c <itrunc+0x3e>

0000000080002f8a <iput>:
{
    80002f8a:	1101                	addi	sp,sp,-32
    80002f8c:	ec06                	sd	ra,24(sp)
    80002f8e:	e822                	sd	s0,16(sp)
    80002f90:	e426                	sd	s1,8(sp)
    80002f92:	e04a                	sd	s2,0(sp)
    80002f94:	1000                	addi	s0,sp,32
    80002f96:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002f98:	00114517          	auipc	a0,0x114
    80002f9c:	02050513          	addi	a0,a0,32 # 80116fb8 <itable>
    80002fa0:	00003097          	auipc	ra,0x3
    80002fa4:	41a080e7          	jalr	1050(ra) # 800063ba <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002fa8:	4498                	lw	a4,8(s1)
    80002faa:	4785                	li	a5,1
    80002fac:	02f70363          	beq	a4,a5,80002fd2 <iput+0x48>
  ip->ref--;
    80002fb0:	449c                	lw	a5,8(s1)
    80002fb2:	37fd                	addiw	a5,a5,-1
    80002fb4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002fb6:	00114517          	auipc	a0,0x114
    80002fba:	00250513          	addi	a0,a0,2 # 80116fb8 <itable>
    80002fbe:	00003097          	auipc	ra,0x3
    80002fc2:	4b0080e7          	jalr	1200(ra) # 8000646e <release>
}
    80002fc6:	60e2                	ld	ra,24(sp)
    80002fc8:	6442                	ld	s0,16(sp)
    80002fca:	64a2                	ld	s1,8(sp)
    80002fcc:	6902                	ld	s2,0(sp)
    80002fce:	6105                	addi	sp,sp,32
    80002fd0:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002fd2:	40bc                	lw	a5,64(s1)
    80002fd4:	dff1                	beqz	a5,80002fb0 <iput+0x26>
    80002fd6:	04a49783          	lh	a5,74(s1)
    80002fda:	fbf9                	bnez	a5,80002fb0 <iput+0x26>
    acquiresleep(&ip->lock);
    80002fdc:	01048913          	addi	s2,s1,16
    80002fe0:	854a                	mv	a0,s2
    80002fe2:	00001097          	auipc	ra,0x1
    80002fe6:	aa8080e7          	jalr	-1368(ra) # 80003a8a <acquiresleep>
    release(&itable.lock);
    80002fea:	00114517          	auipc	a0,0x114
    80002fee:	fce50513          	addi	a0,a0,-50 # 80116fb8 <itable>
    80002ff2:	00003097          	auipc	ra,0x3
    80002ff6:	47c080e7          	jalr	1148(ra) # 8000646e <release>
    itrunc(ip);
    80002ffa:	8526                	mv	a0,s1
    80002ffc:	00000097          	auipc	ra,0x0
    80003000:	ee2080e7          	jalr	-286(ra) # 80002ede <itrunc>
    ip->type = 0;
    80003004:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003008:	8526                	mv	a0,s1
    8000300a:	00000097          	auipc	ra,0x0
    8000300e:	cfc080e7          	jalr	-772(ra) # 80002d06 <iupdate>
    ip->valid = 0;
    80003012:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003016:	854a                	mv	a0,s2
    80003018:	00001097          	auipc	ra,0x1
    8000301c:	ac8080e7          	jalr	-1336(ra) # 80003ae0 <releasesleep>
    acquire(&itable.lock);
    80003020:	00114517          	auipc	a0,0x114
    80003024:	f9850513          	addi	a0,a0,-104 # 80116fb8 <itable>
    80003028:	00003097          	auipc	ra,0x3
    8000302c:	392080e7          	jalr	914(ra) # 800063ba <acquire>
    80003030:	b741                	j	80002fb0 <iput+0x26>

0000000080003032 <iunlockput>:
{
    80003032:	1101                	addi	sp,sp,-32
    80003034:	ec06                	sd	ra,24(sp)
    80003036:	e822                	sd	s0,16(sp)
    80003038:	e426                	sd	s1,8(sp)
    8000303a:	1000                	addi	s0,sp,32
    8000303c:	84aa                	mv	s1,a0
  iunlock(ip);
    8000303e:	00000097          	auipc	ra,0x0
    80003042:	e54080e7          	jalr	-428(ra) # 80002e92 <iunlock>
  iput(ip);
    80003046:	8526                	mv	a0,s1
    80003048:	00000097          	auipc	ra,0x0
    8000304c:	f42080e7          	jalr	-190(ra) # 80002f8a <iput>
}
    80003050:	60e2                	ld	ra,24(sp)
    80003052:	6442                	ld	s0,16(sp)
    80003054:	64a2                	ld	s1,8(sp)
    80003056:	6105                	addi	sp,sp,32
    80003058:	8082                	ret

000000008000305a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000305a:	1141                	addi	sp,sp,-16
    8000305c:	e422                	sd	s0,8(sp)
    8000305e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003060:	411c                	lw	a5,0(a0)
    80003062:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003064:	415c                	lw	a5,4(a0)
    80003066:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003068:	04451783          	lh	a5,68(a0)
    8000306c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003070:	04a51783          	lh	a5,74(a0)
    80003074:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003078:	04c56783          	lwu	a5,76(a0)
    8000307c:	e99c                	sd	a5,16(a1)
}
    8000307e:	6422                	ld	s0,8(sp)
    80003080:	0141                	addi	sp,sp,16
    80003082:	8082                	ret

0000000080003084 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003084:	457c                	lw	a5,76(a0)
    80003086:	0ed7e963          	bltu	a5,a3,80003178 <readi+0xf4>
{
    8000308a:	7159                	addi	sp,sp,-112
    8000308c:	f486                	sd	ra,104(sp)
    8000308e:	f0a2                	sd	s0,96(sp)
    80003090:	eca6                	sd	s1,88(sp)
    80003092:	e8ca                	sd	s2,80(sp)
    80003094:	e4ce                	sd	s3,72(sp)
    80003096:	e0d2                	sd	s4,64(sp)
    80003098:	fc56                	sd	s5,56(sp)
    8000309a:	f85a                	sd	s6,48(sp)
    8000309c:	f45e                	sd	s7,40(sp)
    8000309e:	f062                	sd	s8,32(sp)
    800030a0:	ec66                	sd	s9,24(sp)
    800030a2:	e86a                	sd	s10,16(sp)
    800030a4:	e46e                	sd	s11,8(sp)
    800030a6:	1880                	addi	s0,sp,112
    800030a8:	8b2a                	mv	s6,a0
    800030aa:	8bae                	mv	s7,a1
    800030ac:	8a32                	mv	s4,a2
    800030ae:	84b6                	mv	s1,a3
    800030b0:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800030b2:	9f35                	addw	a4,a4,a3
    return 0;
    800030b4:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800030b6:	0ad76063          	bltu	a4,a3,80003156 <readi+0xd2>
  if(off + n > ip->size)
    800030ba:	00e7f463          	bgeu	a5,a4,800030c2 <readi+0x3e>
    n = ip->size - off;
    800030be:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800030c2:	0a0a8963          	beqz	s5,80003174 <readi+0xf0>
    800030c6:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800030c8:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800030cc:	5c7d                	li	s8,-1
    800030ce:	a82d                	j	80003108 <readi+0x84>
    800030d0:	020d1d93          	slli	s11,s10,0x20
    800030d4:	020ddd93          	srli	s11,s11,0x20
    800030d8:	05890793          	addi	a5,s2,88
    800030dc:	86ee                	mv	a3,s11
    800030de:	963e                	add	a2,a2,a5
    800030e0:	85d2                	mv	a1,s4
    800030e2:	855e                	mv	a0,s7
    800030e4:	fffff097          	auipc	ra,0xfffff
    800030e8:	aba080e7          	jalr	-1350(ra) # 80001b9e <either_copyout>
    800030ec:	05850d63          	beq	a0,s8,80003146 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800030f0:	854a                	mv	a0,s2
    800030f2:	fffff097          	auipc	ra,0xfffff
    800030f6:	5f4080e7          	jalr	1524(ra) # 800026e6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800030fa:	013d09bb          	addw	s3,s10,s3
    800030fe:	009d04bb          	addw	s1,s10,s1
    80003102:	9a6e                	add	s4,s4,s11
    80003104:	0559f763          	bgeu	s3,s5,80003152 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003108:	00a4d59b          	srliw	a1,s1,0xa
    8000310c:	855a                	mv	a0,s6
    8000310e:	00000097          	auipc	ra,0x0
    80003112:	8a2080e7          	jalr	-1886(ra) # 800029b0 <bmap>
    80003116:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000311a:	cd85                	beqz	a1,80003152 <readi+0xce>
    bp = bread(ip->dev, addr);
    8000311c:	000b2503          	lw	a0,0(s6)
    80003120:	fffff097          	auipc	ra,0xfffff
    80003124:	496080e7          	jalr	1174(ra) # 800025b6 <bread>
    80003128:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000312a:	3ff4f613          	andi	a2,s1,1023
    8000312e:	40cc87bb          	subw	a5,s9,a2
    80003132:	413a873b          	subw	a4,s5,s3
    80003136:	8d3e                	mv	s10,a5
    80003138:	2781                	sext.w	a5,a5
    8000313a:	0007069b          	sext.w	a3,a4
    8000313e:	f8f6f9e3          	bgeu	a3,a5,800030d0 <readi+0x4c>
    80003142:	8d3a                	mv	s10,a4
    80003144:	b771                	j	800030d0 <readi+0x4c>
      brelse(bp);
    80003146:	854a                	mv	a0,s2
    80003148:	fffff097          	auipc	ra,0xfffff
    8000314c:	59e080e7          	jalr	1438(ra) # 800026e6 <brelse>
      tot = -1;
    80003150:	59fd                	li	s3,-1
  }
  return tot;
    80003152:	0009851b          	sext.w	a0,s3
}
    80003156:	70a6                	ld	ra,104(sp)
    80003158:	7406                	ld	s0,96(sp)
    8000315a:	64e6                	ld	s1,88(sp)
    8000315c:	6946                	ld	s2,80(sp)
    8000315e:	69a6                	ld	s3,72(sp)
    80003160:	6a06                	ld	s4,64(sp)
    80003162:	7ae2                	ld	s5,56(sp)
    80003164:	7b42                	ld	s6,48(sp)
    80003166:	7ba2                	ld	s7,40(sp)
    80003168:	7c02                	ld	s8,32(sp)
    8000316a:	6ce2                	ld	s9,24(sp)
    8000316c:	6d42                	ld	s10,16(sp)
    8000316e:	6da2                	ld	s11,8(sp)
    80003170:	6165                	addi	sp,sp,112
    80003172:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003174:	89d6                	mv	s3,s5
    80003176:	bff1                	j	80003152 <readi+0xce>
    return 0;
    80003178:	4501                	li	a0,0
}
    8000317a:	8082                	ret

000000008000317c <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000317c:	457c                	lw	a5,76(a0)
    8000317e:	10d7e863          	bltu	a5,a3,8000328e <writei+0x112>
{
    80003182:	7159                	addi	sp,sp,-112
    80003184:	f486                	sd	ra,104(sp)
    80003186:	f0a2                	sd	s0,96(sp)
    80003188:	eca6                	sd	s1,88(sp)
    8000318a:	e8ca                	sd	s2,80(sp)
    8000318c:	e4ce                	sd	s3,72(sp)
    8000318e:	e0d2                	sd	s4,64(sp)
    80003190:	fc56                	sd	s5,56(sp)
    80003192:	f85a                	sd	s6,48(sp)
    80003194:	f45e                	sd	s7,40(sp)
    80003196:	f062                	sd	s8,32(sp)
    80003198:	ec66                	sd	s9,24(sp)
    8000319a:	e86a                	sd	s10,16(sp)
    8000319c:	e46e                	sd	s11,8(sp)
    8000319e:	1880                	addi	s0,sp,112
    800031a0:	8aaa                	mv	s5,a0
    800031a2:	8bae                	mv	s7,a1
    800031a4:	8a32                	mv	s4,a2
    800031a6:	8936                	mv	s2,a3
    800031a8:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800031aa:	00e687bb          	addw	a5,a3,a4
    800031ae:	0ed7e263          	bltu	a5,a3,80003292 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800031b2:	00043737          	lui	a4,0x43
    800031b6:	0ef76063          	bltu	a4,a5,80003296 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800031ba:	0c0b0863          	beqz	s6,8000328a <writei+0x10e>
    800031be:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800031c0:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800031c4:	5c7d                	li	s8,-1
    800031c6:	a091                	j	8000320a <writei+0x8e>
    800031c8:	020d1d93          	slli	s11,s10,0x20
    800031cc:	020ddd93          	srli	s11,s11,0x20
    800031d0:	05848793          	addi	a5,s1,88
    800031d4:	86ee                	mv	a3,s11
    800031d6:	8652                	mv	a2,s4
    800031d8:	85de                	mv	a1,s7
    800031da:	953e                	add	a0,a0,a5
    800031dc:	fffff097          	auipc	ra,0xfffff
    800031e0:	a18080e7          	jalr	-1512(ra) # 80001bf4 <either_copyin>
    800031e4:	07850263          	beq	a0,s8,80003248 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800031e8:	8526                	mv	a0,s1
    800031ea:	00000097          	auipc	ra,0x0
    800031ee:	780080e7          	jalr	1920(ra) # 8000396a <log_write>
    brelse(bp);
    800031f2:	8526                	mv	a0,s1
    800031f4:	fffff097          	auipc	ra,0xfffff
    800031f8:	4f2080e7          	jalr	1266(ra) # 800026e6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800031fc:	013d09bb          	addw	s3,s10,s3
    80003200:	012d093b          	addw	s2,s10,s2
    80003204:	9a6e                	add	s4,s4,s11
    80003206:	0569f663          	bgeu	s3,s6,80003252 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    8000320a:	00a9559b          	srliw	a1,s2,0xa
    8000320e:	8556                	mv	a0,s5
    80003210:	fffff097          	auipc	ra,0xfffff
    80003214:	7a0080e7          	jalr	1952(ra) # 800029b0 <bmap>
    80003218:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000321c:	c99d                	beqz	a1,80003252 <writei+0xd6>
    bp = bread(ip->dev, addr);
    8000321e:	000aa503          	lw	a0,0(s5)
    80003222:	fffff097          	auipc	ra,0xfffff
    80003226:	394080e7          	jalr	916(ra) # 800025b6 <bread>
    8000322a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000322c:	3ff97513          	andi	a0,s2,1023
    80003230:	40ac87bb          	subw	a5,s9,a0
    80003234:	413b073b          	subw	a4,s6,s3
    80003238:	8d3e                	mv	s10,a5
    8000323a:	2781                	sext.w	a5,a5
    8000323c:	0007069b          	sext.w	a3,a4
    80003240:	f8f6f4e3          	bgeu	a3,a5,800031c8 <writei+0x4c>
    80003244:	8d3a                	mv	s10,a4
    80003246:	b749                	j	800031c8 <writei+0x4c>
      brelse(bp);
    80003248:	8526                	mv	a0,s1
    8000324a:	fffff097          	auipc	ra,0xfffff
    8000324e:	49c080e7          	jalr	1180(ra) # 800026e6 <brelse>
  }

  if(off > ip->size)
    80003252:	04caa783          	lw	a5,76(s5)
    80003256:	0127f463          	bgeu	a5,s2,8000325e <writei+0xe2>
    ip->size = off;
    8000325a:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000325e:	8556                	mv	a0,s5
    80003260:	00000097          	auipc	ra,0x0
    80003264:	aa6080e7          	jalr	-1370(ra) # 80002d06 <iupdate>

  return tot;
    80003268:	0009851b          	sext.w	a0,s3
}
    8000326c:	70a6                	ld	ra,104(sp)
    8000326e:	7406                	ld	s0,96(sp)
    80003270:	64e6                	ld	s1,88(sp)
    80003272:	6946                	ld	s2,80(sp)
    80003274:	69a6                	ld	s3,72(sp)
    80003276:	6a06                	ld	s4,64(sp)
    80003278:	7ae2                	ld	s5,56(sp)
    8000327a:	7b42                	ld	s6,48(sp)
    8000327c:	7ba2                	ld	s7,40(sp)
    8000327e:	7c02                	ld	s8,32(sp)
    80003280:	6ce2                	ld	s9,24(sp)
    80003282:	6d42                	ld	s10,16(sp)
    80003284:	6da2                	ld	s11,8(sp)
    80003286:	6165                	addi	sp,sp,112
    80003288:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000328a:	89da                	mv	s3,s6
    8000328c:	bfc9                	j	8000325e <writei+0xe2>
    return -1;
    8000328e:	557d                	li	a0,-1
}
    80003290:	8082                	ret
    return -1;
    80003292:	557d                	li	a0,-1
    80003294:	bfe1                	j	8000326c <writei+0xf0>
    return -1;
    80003296:	557d                	li	a0,-1
    80003298:	bfd1                	j	8000326c <writei+0xf0>

000000008000329a <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000329a:	1141                	addi	sp,sp,-16
    8000329c:	e406                	sd	ra,8(sp)
    8000329e:	e022                	sd	s0,0(sp)
    800032a0:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800032a2:	4639                	li	a2,14
    800032a4:	ffffd097          	auipc	ra,0xffffd
    800032a8:	0f2080e7          	jalr	242(ra) # 80000396 <strncmp>
}
    800032ac:	60a2                	ld	ra,8(sp)
    800032ae:	6402                	ld	s0,0(sp)
    800032b0:	0141                	addi	sp,sp,16
    800032b2:	8082                	ret

00000000800032b4 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800032b4:	7139                	addi	sp,sp,-64
    800032b6:	fc06                	sd	ra,56(sp)
    800032b8:	f822                	sd	s0,48(sp)
    800032ba:	f426                	sd	s1,40(sp)
    800032bc:	f04a                	sd	s2,32(sp)
    800032be:	ec4e                	sd	s3,24(sp)
    800032c0:	e852                	sd	s4,16(sp)
    800032c2:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800032c4:	04451703          	lh	a4,68(a0)
    800032c8:	4785                	li	a5,1
    800032ca:	00f71a63          	bne	a4,a5,800032de <dirlookup+0x2a>
    800032ce:	892a                	mv	s2,a0
    800032d0:	89ae                	mv	s3,a1
    800032d2:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800032d4:	457c                	lw	a5,76(a0)
    800032d6:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800032d8:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800032da:	e79d                	bnez	a5,80003308 <dirlookup+0x54>
    800032dc:	a8a5                	j	80003354 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800032de:	00005517          	auipc	a0,0x5
    800032e2:	2fa50513          	addi	a0,a0,762 # 800085d8 <syscalls+0x1a0>
    800032e6:	00003097          	auipc	ra,0x3
    800032ea:	b98080e7          	jalr	-1128(ra) # 80005e7e <panic>
      panic("dirlookup read");
    800032ee:	00005517          	auipc	a0,0x5
    800032f2:	30250513          	addi	a0,a0,770 # 800085f0 <syscalls+0x1b8>
    800032f6:	00003097          	auipc	ra,0x3
    800032fa:	b88080e7          	jalr	-1144(ra) # 80005e7e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800032fe:	24c1                	addiw	s1,s1,16
    80003300:	04c92783          	lw	a5,76(s2)
    80003304:	04f4f763          	bgeu	s1,a5,80003352 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003308:	4741                	li	a4,16
    8000330a:	86a6                	mv	a3,s1
    8000330c:	fc040613          	addi	a2,s0,-64
    80003310:	4581                	li	a1,0
    80003312:	854a                	mv	a0,s2
    80003314:	00000097          	auipc	ra,0x0
    80003318:	d70080e7          	jalr	-656(ra) # 80003084 <readi>
    8000331c:	47c1                	li	a5,16
    8000331e:	fcf518e3          	bne	a0,a5,800032ee <dirlookup+0x3a>
    if(de.inum == 0)
    80003322:	fc045783          	lhu	a5,-64(s0)
    80003326:	dfe1                	beqz	a5,800032fe <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003328:	fc240593          	addi	a1,s0,-62
    8000332c:	854e                	mv	a0,s3
    8000332e:	00000097          	auipc	ra,0x0
    80003332:	f6c080e7          	jalr	-148(ra) # 8000329a <namecmp>
    80003336:	f561                	bnez	a0,800032fe <dirlookup+0x4a>
      if(poff)
    80003338:	000a0463          	beqz	s4,80003340 <dirlookup+0x8c>
        *poff = off;
    8000333c:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003340:	fc045583          	lhu	a1,-64(s0)
    80003344:	00092503          	lw	a0,0(s2)
    80003348:	fffff097          	auipc	ra,0xfffff
    8000334c:	750080e7          	jalr	1872(ra) # 80002a98 <iget>
    80003350:	a011                	j	80003354 <dirlookup+0xa0>
  return 0;
    80003352:	4501                	li	a0,0
}
    80003354:	70e2                	ld	ra,56(sp)
    80003356:	7442                	ld	s0,48(sp)
    80003358:	74a2                	ld	s1,40(sp)
    8000335a:	7902                	ld	s2,32(sp)
    8000335c:	69e2                	ld	s3,24(sp)
    8000335e:	6a42                	ld	s4,16(sp)
    80003360:	6121                	addi	sp,sp,64
    80003362:	8082                	ret

0000000080003364 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003364:	711d                	addi	sp,sp,-96
    80003366:	ec86                	sd	ra,88(sp)
    80003368:	e8a2                	sd	s0,80(sp)
    8000336a:	e4a6                	sd	s1,72(sp)
    8000336c:	e0ca                	sd	s2,64(sp)
    8000336e:	fc4e                	sd	s3,56(sp)
    80003370:	f852                	sd	s4,48(sp)
    80003372:	f456                	sd	s5,40(sp)
    80003374:	f05a                	sd	s6,32(sp)
    80003376:	ec5e                	sd	s7,24(sp)
    80003378:	e862                	sd	s8,16(sp)
    8000337a:	e466                	sd	s9,8(sp)
    8000337c:	1080                	addi	s0,sp,96
    8000337e:	84aa                	mv	s1,a0
    80003380:	8aae                	mv	s5,a1
    80003382:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003384:	00054703          	lbu	a4,0(a0)
    80003388:	02f00793          	li	a5,47
    8000338c:	02f70363          	beq	a4,a5,800033b2 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003390:	ffffe097          	auipc	ra,0xffffe
    80003394:	d5a080e7          	jalr	-678(ra) # 800010ea <myproc>
    80003398:	15053503          	ld	a0,336(a0)
    8000339c:	00000097          	auipc	ra,0x0
    800033a0:	9f6080e7          	jalr	-1546(ra) # 80002d92 <idup>
    800033a4:	89aa                	mv	s3,a0
  while(*path == '/')
    800033a6:	02f00913          	li	s2,47
  len = path - s;
    800033aa:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    800033ac:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800033ae:	4b85                	li	s7,1
    800033b0:	a865                	j	80003468 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    800033b2:	4585                	li	a1,1
    800033b4:	4505                	li	a0,1
    800033b6:	fffff097          	auipc	ra,0xfffff
    800033ba:	6e2080e7          	jalr	1762(ra) # 80002a98 <iget>
    800033be:	89aa                	mv	s3,a0
    800033c0:	b7dd                	j	800033a6 <namex+0x42>
      iunlockput(ip);
    800033c2:	854e                	mv	a0,s3
    800033c4:	00000097          	auipc	ra,0x0
    800033c8:	c6e080e7          	jalr	-914(ra) # 80003032 <iunlockput>
      return 0;
    800033cc:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800033ce:	854e                	mv	a0,s3
    800033d0:	60e6                	ld	ra,88(sp)
    800033d2:	6446                	ld	s0,80(sp)
    800033d4:	64a6                	ld	s1,72(sp)
    800033d6:	6906                	ld	s2,64(sp)
    800033d8:	79e2                	ld	s3,56(sp)
    800033da:	7a42                	ld	s4,48(sp)
    800033dc:	7aa2                	ld	s5,40(sp)
    800033de:	7b02                	ld	s6,32(sp)
    800033e0:	6be2                	ld	s7,24(sp)
    800033e2:	6c42                	ld	s8,16(sp)
    800033e4:	6ca2                	ld	s9,8(sp)
    800033e6:	6125                	addi	sp,sp,96
    800033e8:	8082                	ret
      iunlock(ip);
    800033ea:	854e                	mv	a0,s3
    800033ec:	00000097          	auipc	ra,0x0
    800033f0:	aa6080e7          	jalr	-1370(ra) # 80002e92 <iunlock>
      return ip;
    800033f4:	bfe9                	j	800033ce <namex+0x6a>
      iunlockput(ip);
    800033f6:	854e                	mv	a0,s3
    800033f8:	00000097          	auipc	ra,0x0
    800033fc:	c3a080e7          	jalr	-966(ra) # 80003032 <iunlockput>
      return 0;
    80003400:	89e6                	mv	s3,s9
    80003402:	b7f1                	j	800033ce <namex+0x6a>
  len = path - s;
    80003404:	40b48633          	sub	a2,s1,a1
    80003408:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    8000340c:	099c5463          	bge	s8,s9,80003494 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003410:	4639                	li	a2,14
    80003412:	8552                	mv	a0,s4
    80003414:	ffffd097          	auipc	ra,0xffffd
    80003418:	f0e080e7          	jalr	-242(ra) # 80000322 <memmove>
  while(*path == '/')
    8000341c:	0004c783          	lbu	a5,0(s1)
    80003420:	01279763          	bne	a5,s2,8000342e <namex+0xca>
    path++;
    80003424:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003426:	0004c783          	lbu	a5,0(s1)
    8000342a:	ff278de3          	beq	a5,s2,80003424 <namex+0xc0>
    ilock(ip);
    8000342e:	854e                	mv	a0,s3
    80003430:	00000097          	auipc	ra,0x0
    80003434:	9a0080e7          	jalr	-1632(ra) # 80002dd0 <ilock>
    if(ip->type != T_DIR){
    80003438:	04499783          	lh	a5,68(s3)
    8000343c:	f97793e3          	bne	a5,s7,800033c2 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003440:	000a8563          	beqz	s5,8000344a <namex+0xe6>
    80003444:	0004c783          	lbu	a5,0(s1)
    80003448:	d3cd                	beqz	a5,800033ea <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000344a:	865a                	mv	a2,s6
    8000344c:	85d2                	mv	a1,s4
    8000344e:	854e                	mv	a0,s3
    80003450:	00000097          	auipc	ra,0x0
    80003454:	e64080e7          	jalr	-412(ra) # 800032b4 <dirlookup>
    80003458:	8caa                	mv	s9,a0
    8000345a:	dd51                	beqz	a0,800033f6 <namex+0x92>
    iunlockput(ip);
    8000345c:	854e                	mv	a0,s3
    8000345e:	00000097          	auipc	ra,0x0
    80003462:	bd4080e7          	jalr	-1068(ra) # 80003032 <iunlockput>
    ip = next;
    80003466:	89e6                	mv	s3,s9
  while(*path == '/')
    80003468:	0004c783          	lbu	a5,0(s1)
    8000346c:	05279763          	bne	a5,s2,800034ba <namex+0x156>
    path++;
    80003470:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003472:	0004c783          	lbu	a5,0(s1)
    80003476:	ff278de3          	beq	a5,s2,80003470 <namex+0x10c>
  if(*path == 0)
    8000347a:	c79d                	beqz	a5,800034a8 <namex+0x144>
    path++;
    8000347c:	85a6                	mv	a1,s1
  len = path - s;
    8000347e:	8cda                	mv	s9,s6
    80003480:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003482:	01278963          	beq	a5,s2,80003494 <namex+0x130>
    80003486:	dfbd                	beqz	a5,80003404 <namex+0xa0>
    path++;
    80003488:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000348a:	0004c783          	lbu	a5,0(s1)
    8000348e:	ff279ce3          	bne	a5,s2,80003486 <namex+0x122>
    80003492:	bf8d                	j	80003404 <namex+0xa0>
    memmove(name, s, len);
    80003494:	2601                	sext.w	a2,a2
    80003496:	8552                	mv	a0,s4
    80003498:	ffffd097          	auipc	ra,0xffffd
    8000349c:	e8a080e7          	jalr	-374(ra) # 80000322 <memmove>
    name[len] = 0;
    800034a0:	9cd2                	add	s9,s9,s4
    800034a2:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800034a6:	bf9d                	j	8000341c <namex+0xb8>
  if(nameiparent){
    800034a8:	f20a83e3          	beqz	s5,800033ce <namex+0x6a>
    iput(ip);
    800034ac:	854e                	mv	a0,s3
    800034ae:	00000097          	auipc	ra,0x0
    800034b2:	adc080e7          	jalr	-1316(ra) # 80002f8a <iput>
    return 0;
    800034b6:	4981                	li	s3,0
    800034b8:	bf19                	j	800033ce <namex+0x6a>
  if(*path == 0)
    800034ba:	d7fd                	beqz	a5,800034a8 <namex+0x144>
  while(*path != '/' && *path != 0)
    800034bc:	0004c783          	lbu	a5,0(s1)
    800034c0:	85a6                	mv	a1,s1
    800034c2:	b7d1                	j	80003486 <namex+0x122>

00000000800034c4 <dirlink>:
{
    800034c4:	7139                	addi	sp,sp,-64
    800034c6:	fc06                	sd	ra,56(sp)
    800034c8:	f822                	sd	s0,48(sp)
    800034ca:	f426                	sd	s1,40(sp)
    800034cc:	f04a                	sd	s2,32(sp)
    800034ce:	ec4e                	sd	s3,24(sp)
    800034d0:	e852                	sd	s4,16(sp)
    800034d2:	0080                	addi	s0,sp,64
    800034d4:	892a                	mv	s2,a0
    800034d6:	8a2e                	mv	s4,a1
    800034d8:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800034da:	4601                	li	a2,0
    800034dc:	00000097          	auipc	ra,0x0
    800034e0:	dd8080e7          	jalr	-552(ra) # 800032b4 <dirlookup>
    800034e4:	e93d                	bnez	a0,8000355a <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800034e6:	04c92483          	lw	s1,76(s2)
    800034ea:	c49d                	beqz	s1,80003518 <dirlink+0x54>
    800034ec:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800034ee:	4741                	li	a4,16
    800034f0:	86a6                	mv	a3,s1
    800034f2:	fc040613          	addi	a2,s0,-64
    800034f6:	4581                	li	a1,0
    800034f8:	854a                	mv	a0,s2
    800034fa:	00000097          	auipc	ra,0x0
    800034fe:	b8a080e7          	jalr	-1142(ra) # 80003084 <readi>
    80003502:	47c1                	li	a5,16
    80003504:	06f51163          	bne	a0,a5,80003566 <dirlink+0xa2>
    if(de.inum == 0)
    80003508:	fc045783          	lhu	a5,-64(s0)
    8000350c:	c791                	beqz	a5,80003518 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000350e:	24c1                	addiw	s1,s1,16
    80003510:	04c92783          	lw	a5,76(s2)
    80003514:	fcf4ede3          	bltu	s1,a5,800034ee <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003518:	4639                	li	a2,14
    8000351a:	85d2                	mv	a1,s4
    8000351c:	fc240513          	addi	a0,s0,-62
    80003520:	ffffd097          	auipc	ra,0xffffd
    80003524:	eb2080e7          	jalr	-334(ra) # 800003d2 <strncpy>
  de.inum = inum;
    80003528:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000352c:	4741                	li	a4,16
    8000352e:	86a6                	mv	a3,s1
    80003530:	fc040613          	addi	a2,s0,-64
    80003534:	4581                	li	a1,0
    80003536:	854a                	mv	a0,s2
    80003538:	00000097          	auipc	ra,0x0
    8000353c:	c44080e7          	jalr	-956(ra) # 8000317c <writei>
    80003540:	1541                	addi	a0,a0,-16
    80003542:	00a03533          	snez	a0,a0
    80003546:	40a00533          	neg	a0,a0
}
    8000354a:	70e2                	ld	ra,56(sp)
    8000354c:	7442                	ld	s0,48(sp)
    8000354e:	74a2                	ld	s1,40(sp)
    80003550:	7902                	ld	s2,32(sp)
    80003552:	69e2                	ld	s3,24(sp)
    80003554:	6a42                	ld	s4,16(sp)
    80003556:	6121                	addi	sp,sp,64
    80003558:	8082                	ret
    iput(ip);
    8000355a:	00000097          	auipc	ra,0x0
    8000355e:	a30080e7          	jalr	-1488(ra) # 80002f8a <iput>
    return -1;
    80003562:	557d                	li	a0,-1
    80003564:	b7dd                	j	8000354a <dirlink+0x86>
      panic("dirlink read");
    80003566:	00005517          	auipc	a0,0x5
    8000356a:	09a50513          	addi	a0,a0,154 # 80008600 <syscalls+0x1c8>
    8000356e:	00003097          	auipc	ra,0x3
    80003572:	910080e7          	jalr	-1776(ra) # 80005e7e <panic>

0000000080003576 <namei>:

struct inode*
namei(char *path)
{
    80003576:	1101                	addi	sp,sp,-32
    80003578:	ec06                	sd	ra,24(sp)
    8000357a:	e822                	sd	s0,16(sp)
    8000357c:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000357e:	fe040613          	addi	a2,s0,-32
    80003582:	4581                	li	a1,0
    80003584:	00000097          	auipc	ra,0x0
    80003588:	de0080e7          	jalr	-544(ra) # 80003364 <namex>
}
    8000358c:	60e2                	ld	ra,24(sp)
    8000358e:	6442                	ld	s0,16(sp)
    80003590:	6105                	addi	sp,sp,32
    80003592:	8082                	ret

0000000080003594 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003594:	1141                	addi	sp,sp,-16
    80003596:	e406                	sd	ra,8(sp)
    80003598:	e022                	sd	s0,0(sp)
    8000359a:	0800                	addi	s0,sp,16
    8000359c:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000359e:	4585                	li	a1,1
    800035a0:	00000097          	auipc	ra,0x0
    800035a4:	dc4080e7          	jalr	-572(ra) # 80003364 <namex>
}
    800035a8:	60a2                	ld	ra,8(sp)
    800035aa:	6402                	ld	s0,0(sp)
    800035ac:	0141                	addi	sp,sp,16
    800035ae:	8082                	ret

00000000800035b0 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800035b0:	1101                	addi	sp,sp,-32
    800035b2:	ec06                	sd	ra,24(sp)
    800035b4:	e822                	sd	s0,16(sp)
    800035b6:	e426                	sd	s1,8(sp)
    800035b8:	e04a                	sd	s2,0(sp)
    800035ba:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800035bc:	00115917          	auipc	s2,0x115
    800035c0:	4a490913          	addi	s2,s2,1188 # 80118a60 <log>
    800035c4:	01892583          	lw	a1,24(s2)
    800035c8:	02892503          	lw	a0,40(s2)
    800035cc:	fffff097          	auipc	ra,0xfffff
    800035d0:	fea080e7          	jalr	-22(ra) # 800025b6 <bread>
    800035d4:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800035d6:	02c92683          	lw	a3,44(s2)
    800035da:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800035dc:	02d05763          	blez	a3,8000360a <write_head+0x5a>
    800035e0:	00115797          	auipc	a5,0x115
    800035e4:	4b078793          	addi	a5,a5,1200 # 80118a90 <log+0x30>
    800035e8:	05c50713          	addi	a4,a0,92
    800035ec:	36fd                	addiw	a3,a3,-1
    800035ee:	1682                	slli	a3,a3,0x20
    800035f0:	9281                	srli	a3,a3,0x20
    800035f2:	068a                	slli	a3,a3,0x2
    800035f4:	00115617          	auipc	a2,0x115
    800035f8:	4a060613          	addi	a2,a2,1184 # 80118a94 <log+0x34>
    800035fc:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800035fe:	4390                	lw	a2,0(a5)
    80003600:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003602:	0791                	addi	a5,a5,4
    80003604:	0711                	addi	a4,a4,4
    80003606:	fed79ce3          	bne	a5,a3,800035fe <write_head+0x4e>
  }
  bwrite(buf);
    8000360a:	8526                	mv	a0,s1
    8000360c:	fffff097          	auipc	ra,0xfffff
    80003610:	09c080e7          	jalr	156(ra) # 800026a8 <bwrite>
  brelse(buf);
    80003614:	8526                	mv	a0,s1
    80003616:	fffff097          	auipc	ra,0xfffff
    8000361a:	0d0080e7          	jalr	208(ra) # 800026e6 <brelse>
}
    8000361e:	60e2                	ld	ra,24(sp)
    80003620:	6442                	ld	s0,16(sp)
    80003622:	64a2                	ld	s1,8(sp)
    80003624:	6902                	ld	s2,0(sp)
    80003626:	6105                	addi	sp,sp,32
    80003628:	8082                	ret

000000008000362a <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000362a:	00115797          	auipc	a5,0x115
    8000362e:	4627a783          	lw	a5,1122(a5) # 80118a8c <log+0x2c>
    80003632:	0af05d63          	blez	a5,800036ec <install_trans+0xc2>
{
    80003636:	7139                	addi	sp,sp,-64
    80003638:	fc06                	sd	ra,56(sp)
    8000363a:	f822                	sd	s0,48(sp)
    8000363c:	f426                	sd	s1,40(sp)
    8000363e:	f04a                	sd	s2,32(sp)
    80003640:	ec4e                	sd	s3,24(sp)
    80003642:	e852                	sd	s4,16(sp)
    80003644:	e456                	sd	s5,8(sp)
    80003646:	e05a                	sd	s6,0(sp)
    80003648:	0080                	addi	s0,sp,64
    8000364a:	8b2a                	mv	s6,a0
    8000364c:	00115a97          	auipc	s5,0x115
    80003650:	444a8a93          	addi	s5,s5,1092 # 80118a90 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003654:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003656:	00115997          	auipc	s3,0x115
    8000365a:	40a98993          	addi	s3,s3,1034 # 80118a60 <log>
    8000365e:	a00d                	j	80003680 <install_trans+0x56>
    brelse(lbuf);
    80003660:	854a                	mv	a0,s2
    80003662:	fffff097          	auipc	ra,0xfffff
    80003666:	084080e7          	jalr	132(ra) # 800026e6 <brelse>
    brelse(dbuf);
    8000366a:	8526                	mv	a0,s1
    8000366c:	fffff097          	auipc	ra,0xfffff
    80003670:	07a080e7          	jalr	122(ra) # 800026e6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003674:	2a05                	addiw	s4,s4,1
    80003676:	0a91                	addi	s5,s5,4
    80003678:	02c9a783          	lw	a5,44(s3)
    8000367c:	04fa5e63          	bge	s4,a5,800036d8 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003680:	0189a583          	lw	a1,24(s3)
    80003684:	014585bb          	addw	a1,a1,s4
    80003688:	2585                	addiw	a1,a1,1
    8000368a:	0289a503          	lw	a0,40(s3)
    8000368e:	fffff097          	auipc	ra,0xfffff
    80003692:	f28080e7          	jalr	-216(ra) # 800025b6 <bread>
    80003696:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003698:	000aa583          	lw	a1,0(s5)
    8000369c:	0289a503          	lw	a0,40(s3)
    800036a0:	fffff097          	auipc	ra,0xfffff
    800036a4:	f16080e7          	jalr	-234(ra) # 800025b6 <bread>
    800036a8:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800036aa:	40000613          	li	a2,1024
    800036ae:	05890593          	addi	a1,s2,88
    800036b2:	05850513          	addi	a0,a0,88
    800036b6:	ffffd097          	auipc	ra,0xffffd
    800036ba:	c6c080e7          	jalr	-916(ra) # 80000322 <memmove>
    bwrite(dbuf);  // write dst to disk
    800036be:	8526                	mv	a0,s1
    800036c0:	fffff097          	auipc	ra,0xfffff
    800036c4:	fe8080e7          	jalr	-24(ra) # 800026a8 <bwrite>
    if(recovering == 0)
    800036c8:	f80b1ce3          	bnez	s6,80003660 <install_trans+0x36>
      bunpin(dbuf);
    800036cc:	8526                	mv	a0,s1
    800036ce:	fffff097          	auipc	ra,0xfffff
    800036d2:	0f2080e7          	jalr	242(ra) # 800027c0 <bunpin>
    800036d6:	b769                	j	80003660 <install_trans+0x36>
}
    800036d8:	70e2                	ld	ra,56(sp)
    800036da:	7442                	ld	s0,48(sp)
    800036dc:	74a2                	ld	s1,40(sp)
    800036de:	7902                	ld	s2,32(sp)
    800036e0:	69e2                	ld	s3,24(sp)
    800036e2:	6a42                	ld	s4,16(sp)
    800036e4:	6aa2                	ld	s5,8(sp)
    800036e6:	6b02                	ld	s6,0(sp)
    800036e8:	6121                	addi	sp,sp,64
    800036ea:	8082                	ret
    800036ec:	8082                	ret

00000000800036ee <initlog>:
{
    800036ee:	7179                	addi	sp,sp,-48
    800036f0:	f406                	sd	ra,40(sp)
    800036f2:	f022                	sd	s0,32(sp)
    800036f4:	ec26                	sd	s1,24(sp)
    800036f6:	e84a                	sd	s2,16(sp)
    800036f8:	e44e                	sd	s3,8(sp)
    800036fa:	1800                	addi	s0,sp,48
    800036fc:	892a                	mv	s2,a0
    800036fe:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003700:	00115497          	auipc	s1,0x115
    80003704:	36048493          	addi	s1,s1,864 # 80118a60 <log>
    80003708:	00005597          	auipc	a1,0x5
    8000370c:	f0858593          	addi	a1,a1,-248 # 80008610 <syscalls+0x1d8>
    80003710:	8526                	mv	a0,s1
    80003712:	00003097          	auipc	ra,0x3
    80003716:	c18080e7          	jalr	-1000(ra) # 8000632a <initlock>
  log.start = sb->logstart;
    8000371a:	0149a583          	lw	a1,20(s3)
    8000371e:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003720:	0109a783          	lw	a5,16(s3)
    80003724:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003726:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000372a:	854a                	mv	a0,s2
    8000372c:	fffff097          	auipc	ra,0xfffff
    80003730:	e8a080e7          	jalr	-374(ra) # 800025b6 <bread>
  log.lh.n = lh->n;
    80003734:	4d34                	lw	a3,88(a0)
    80003736:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003738:	02d05563          	blez	a3,80003762 <initlog+0x74>
    8000373c:	05c50793          	addi	a5,a0,92
    80003740:	00115717          	auipc	a4,0x115
    80003744:	35070713          	addi	a4,a4,848 # 80118a90 <log+0x30>
    80003748:	36fd                	addiw	a3,a3,-1
    8000374a:	1682                	slli	a3,a3,0x20
    8000374c:	9281                	srli	a3,a3,0x20
    8000374e:	068a                	slli	a3,a3,0x2
    80003750:	06050613          	addi	a2,a0,96
    80003754:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80003756:	4390                	lw	a2,0(a5)
    80003758:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000375a:	0791                	addi	a5,a5,4
    8000375c:	0711                	addi	a4,a4,4
    8000375e:	fed79ce3          	bne	a5,a3,80003756 <initlog+0x68>
  brelse(buf);
    80003762:	fffff097          	auipc	ra,0xfffff
    80003766:	f84080e7          	jalr	-124(ra) # 800026e6 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000376a:	4505                	li	a0,1
    8000376c:	00000097          	auipc	ra,0x0
    80003770:	ebe080e7          	jalr	-322(ra) # 8000362a <install_trans>
  log.lh.n = 0;
    80003774:	00115797          	auipc	a5,0x115
    80003778:	3007ac23          	sw	zero,792(a5) # 80118a8c <log+0x2c>
  write_head(); // clear the log
    8000377c:	00000097          	auipc	ra,0x0
    80003780:	e34080e7          	jalr	-460(ra) # 800035b0 <write_head>
}
    80003784:	70a2                	ld	ra,40(sp)
    80003786:	7402                	ld	s0,32(sp)
    80003788:	64e2                	ld	s1,24(sp)
    8000378a:	6942                	ld	s2,16(sp)
    8000378c:	69a2                	ld	s3,8(sp)
    8000378e:	6145                	addi	sp,sp,48
    80003790:	8082                	ret

0000000080003792 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003792:	1101                	addi	sp,sp,-32
    80003794:	ec06                	sd	ra,24(sp)
    80003796:	e822                	sd	s0,16(sp)
    80003798:	e426                	sd	s1,8(sp)
    8000379a:	e04a                	sd	s2,0(sp)
    8000379c:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000379e:	00115517          	auipc	a0,0x115
    800037a2:	2c250513          	addi	a0,a0,706 # 80118a60 <log>
    800037a6:	00003097          	auipc	ra,0x3
    800037aa:	c14080e7          	jalr	-1004(ra) # 800063ba <acquire>
  while(1){
    if(log.committing){
    800037ae:	00115497          	auipc	s1,0x115
    800037b2:	2b248493          	addi	s1,s1,690 # 80118a60 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800037b6:	4979                	li	s2,30
    800037b8:	a039                	j	800037c6 <begin_op+0x34>
      sleep(&log, &log.lock);
    800037ba:	85a6                	mv	a1,s1
    800037bc:	8526                	mv	a0,s1
    800037be:	ffffe097          	auipc	ra,0xffffe
    800037c2:	fd8080e7          	jalr	-40(ra) # 80001796 <sleep>
    if(log.committing){
    800037c6:	50dc                	lw	a5,36(s1)
    800037c8:	fbed                	bnez	a5,800037ba <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800037ca:	509c                	lw	a5,32(s1)
    800037cc:	0017871b          	addiw	a4,a5,1
    800037d0:	0007069b          	sext.w	a3,a4
    800037d4:	0027179b          	slliw	a5,a4,0x2
    800037d8:	9fb9                	addw	a5,a5,a4
    800037da:	0017979b          	slliw	a5,a5,0x1
    800037de:	54d8                	lw	a4,44(s1)
    800037e0:	9fb9                	addw	a5,a5,a4
    800037e2:	00f95963          	bge	s2,a5,800037f4 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800037e6:	85a6                	mv	a1,s1
    800037e8:	8526                	mv	a0,s1
    800037ea:	ffffe097          	auipc	ra,0xffffe
    800037ee:	fac080e7          	jalr	-84(ra) # 80001796 <sleep>
    800037f2:	bfd1                	j	800037c6 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800037f4:	00115517          	auipc	a0,0x115
    800037f8:	26c50513          	addi	a0,a0,620 # 80118a60 <log>
    800037fc:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800037fe:	00003097          	auipc	ra,0x3
    80003802:	c70080e7          	jalr	-912(ra) # 8000646e <release>
      break;
    }
  }
}
    80003806:	60e2                	ld	ra,24(sp)
    80003808:	6442                	ld	s0,16(sp)
    8000380a:	64a2                	ld	s1,8(sp)
    8000380c:	6902                	ld	s2,0(sp)
    8000380e:	6105                	addi	sp,sp,32
    80003810:	8082                	ret

0000000080003812 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003812:	7139                	addi	sp,sp,-64
    80003814:	fc06                	sd	ra,56(sp)
    80003816:	f822                	sd	s0,48(sp)
    80003818:	f426                	sd	s1,40(sp)
    8000381a:	f04a                	sd	s2,32(sp)
    8000381c:	ec4e                	sd	s3,24(sp)
    8000381e:	e852                	sd	s4,16(sp)
    80003820:	e456                	sd	s5,8(sp)
    80003822:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003824:	00115497          	auipc	s1,0x115
    80003828:	23c48493          	addi	s1,s1,572 # 80118a60 <log>
    8000382c:	8526                	mv	a0,s1
    8000382e:	00003097          	auipc	ra,0x3
    80003832:	b8c080e7          	jalr	-1140(ra) # 800063ba <acquire>
  log.outstanding -= 1;
    80003836:	509c                	lw	a5,32(s1)
    80003838:	37fd                	addiw	a5,a5,-1
    8000383a:	0007891b          	sext.w	s2,a5
    8000383e:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003840:	50dc                	lw	a5,36(s1)
    80003842:	e7b9                	bnez	a5,80003890 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80003844:	04091e63          	bnez	s2,800038a0 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80003848:	00115497          	auipc	s1,0x115
    8000384c:	21848493          	addi	s1,s1,536 # 80118a60 <log>
    80003850:	4785                	li	a5,1
    80003852:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003854:	8526                	mv	a0,s1
    80003856:	00003097          	auipc	ra,0x3
    8000385a:	c18080e7          	jalr	-1000(ra) # 8000646e <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000385e:	54dc                	lw	a5,44(s1)
    80003860:	06f04763          	bgtz	a5,800038ce <end_op+0xbc>
    acquire(&log.lock);
    80003864:	00115497          	auipc	s1,0x115
    80003868:	1fc48493          	addi	s1,s1,508 # 80118a60 <log>
    8000386c:	8526                	mv	a0,s1
    8000386e:	00003097          	auipc	ra,0x3
    80003872:	b4c080e7          	jalr	-1204(ra) # 800063ba <acquire>
    log.committing = 0;
    80003876:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000387a:	8526                	mv	a0,s1
    8000387c:	ffffe097          	auipc	ra,0xffffe
    80003880:	f7e080e7          	jalr	-130(ra) # 800017fa <wakeup>
    release(&log.lock);
    80003884:	8526                	mv	a0,s1
    80003886:	00003097          	auipc	ra,0x3
    8000388a:	be8080e7          	jalr	-1048(ra) # 8000646e <release>
}
    8000388e:	a03d                	j	800038bc <end_op+0xaa>
    panic("log.committing");
    80003890:	00005517          	auipc	a0,0x5
    80003894:	d8850513          	addi	a0,a0,-632 # 80008618 <syscalls+0x1e0>
    80003898:	00002097          	auipc	ra,0x2
    8000389c:	5e6080e7          	jalr	1510(ra) # 80005e7e <panic>
    wakeup(&log);
    800038a0:	00115497          	auipc	s1,0x115
    800038a4:	1c048493          	addi	s1,s1,448 # 80118a60 <log>
    800038a8:	8526                	mv	a0,s1
    800038aa:	ffffe097          	auipc	ra,0xffffe
    800038ae:	f50080e7          	jalr	-176(ra) # 800017fa <wakeup>
  release(&log.lock);
    800038b2:	8526                	mv	a0,s1
    800038b4:	00003097          	auipc	ra,0x3
    800038b8:	bba080e7          	jalr	-1094(ra) # 8000646e <release>
}
    800038bc:	70e2                	ld	ra,56(sp)
    800038be:	7442                	ld	s0,48(sp)
    800038c0:	74a2                	ld	s1,40(sp)
    800038c2:	7902                	ld	s2,32(sp)
    800038c4:	69e2                	ld	s3,24(sp)
    800038c6:	6a42                	ld	s4,16(sp)
    800038c8:	6aa2                	ld	s5,8(sp)
    800038ca:	6121                	addi	sp,sp,64
    800038cc:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800038ce:	00115a97          	auipc	s5,0x115
    800038d2:	1c2a8a93          	addi	s5,s5,450 # 80118a90 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800038d6:	00115a17          	auipc	s4,0x115
    800038da:	18aa0a13          	addi	s4,s4,394 # 80118a60 <log>
    800038de:	018a2583          	lw	a1,24(s4)
    800038e2:	012585bb          	addw	a1,a1,s2
    800038e6:	2585                	addiw	a1,a1,1
    800038e8:	028a2503          	lw	a0,40(s4)
    800038ec:	fffff097          	auipc	ra,0xfffff
    800038f0:	cca080e7          	jalr	-822(ra) # 800025b6 <bread>
    800038f4:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800038f6:	000aa583          	lw	a1,0(s5)
    800038fa:	028a2503          	lw	a0,40(s4)
    800038fe:	fffff097          	auipc	ra,0xfffff
    80003902:	cb8080e7          	jalr	-840(ra) # 800025b6 <bread>
    80003906:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003908:	40000613          	li	a2,1024
    8000390c:	05850593          	addi	a1,a0,88
    80003910:	05848513          	addi	a0,s1,88
    80003914:	ffffd097          	auipc	ra,0xffffd
    80003918:	a0e080e7          	jalr	-1522(ra) # 80000322 <memmove>
    bwrite(to);  // write the log
    8000391c:	8526                	mv	a0,s1
    8000391e:	fffff097          	auipc	ra,0xfffff
    80003922:	d8a080e7          	jalr	-630(ra) # 800026a8 <bwrite>
    brelse(from);
    80003926:	854e                	mv	a0,s3
    80003928:	fffff097          	auipc	ra,0xfffff
    8000392c:	dbe080e7          	jalr	-578(ra) # 800026e6 <brelse>
    brelse(to);
    80003930:	8526                	mv	a0,s1
    80003932:	fffff097          	auipc	ra,0xfffff
    80003936:	db4080e7          	jalr	-588(ra) # 800026e6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000393a:	2905                	addiw	s2,s2,1
    8000393c:	0a91                	addi	s5,s5,4
    8000393e:	02ca2783          	lw	a5,44(s4)
    80003942:	f8f94ee3          	blt	s2,a5,800038de <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003946:	00000097          	auipc	ra,0x0
    8000394a:	c6a080e7          	jalr	-918(ra) # 800035b0 <write_head>
    install_trans(0); // Now install writes to home locations
    8000394e:	4501                	li	a0,0
    80003950:	00000097          	auipc	ra,0x0
    80003954:	cda080e7          	jalr	-806(ra) # 8000362a <install_trans>
    log.lh.n = 0;
    80003958:	00115797          	auipc	a5,0x115
    8000395c:	1207aa23          	sw	zero,308(a5) # 80118a8c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003960:	00000097          	auipc	ra,0x0
    80003964:	c50080e7          	jalr	-944(ra) # 800035b0 <write_head>
    80003968:	bdf5                	j	80003864 <end_op+0x52>

000000008000396a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000396a:	1101                	addi	sp,sp,-32
    8000396c:	ec06                	sd	ra,24(sp)
    8000396e:	e822                	sd	s0,16(sp)
    80003970:	e426                	sd	s1,8(sp)
    80003972:	e04a                	sd	s2,0(sp)
    80003974:	1000                	addi	s0,sp,32
    80003976:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003978:	00115917          	auipc	s2,0x115
    8000397c:	0e890913          	addi	s2,s2,232 # 80118a60 <log>
    80003980:	854a                	mv	a0,s2
    80003982:	00003097          	auipc	ra,0x3
    80003986:	a38080e7          	jalr	-1480(ra) # 800063ba <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000398a:	02c92603          	lw	a2,44(s2)
    8000398e:	47f5                	li	a5,29
    80003990:	06c7c563          	blt	a5,a2,800039fa <log_write+0x90>
    80003994:	00115797          	auipc	a5,0x115
    80003998:	0e87a783          	lw	a5,232(a5) # 80118a7c <log+0x1c>
    8000399c:	37fd                	addiw	a5,a5,-1
    8000399e:	04f65e63          	bge	a2,a5,800039fa <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800039a2:	00115797          	auipc	a5,0x115
    800039a6:	0de7a783          	lw	a5,222(a5) # 80118a80 <log+0x20>
    800039aa:	06f05063          	blez	a5,80003a0a <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800039ae:	4781                	li	a5,0
    800039b0:	06c05563          	blez	a2,80003a1a <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800039b4:	44cc                	lw	a1,12(s1)
    800039b6:	00115717          	auipc	a4,0x115
    800039ba:	0da70713          	addi	a4,a4,218 # 80118a90 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800039be:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800039c0:	4314                	lw	a3,0(a4)
    800039c2:	04b68c63          	beq	a3,a1,80003a1a <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800039c6:	2785                	addiw	a5,a5,1
    800039c8:	0711                	addi	a4,a4,4
    800039ca:	fef61be3          	bne	a2,a5,800039c0 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800039ce:	0621                	addi	a2,a2,8
    800039d0:	060a                	slli	a2,a2,0x2
    800039d2:	00115797          	auipc	a5,0x115
    800039d6:	08e78793          	addi	a5,a5,142 # 80118a60 <log>
    800039da:	963e                	add	a2,a2,a5
    800039dc:	44dc                	lw	a5,12(s1)
    800039de:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800039e0:	8526                	mv	a0,s1
    800039e2:	fffff097          	auipc	ra,0xfffff
    800039e6:	da2080e7          	jalr	-606(ra) # 80002784 <bpin>
    log.lh.n++;
    800039ea:	00115717          	auipc	a4,0x115
    800039ee:	07670713          	addi	a4,a4,118 # 80118a60 <log>
    800039f2:	575c                	lw	a5,44(a4)
    800039f4:	2785                	addiw	a5,a5,1
    800039f6:	d75c                	sw	a5,44(a4)
    800039f8:	a835                	j	80003a34 <log_write+0xca>
    panic("too big a transaction");
    800039fa:	00005517          	auipc	a0,0x5
    800039fe:	c2e50513          	addi	a0,a0,-978 # 80008628 <syscalls+0x1f0>
    80003a02:	00002097          	auipc	ra,0x2
    80003a06:	47c080e7          	jalr	1148(ra) # 80005e7e <panic>
    panic("log_write outside of trans");
    80003a0a:	00005517          	auipc	a0,0x5
    80003a0e:	c3650513          	addi	a0,a0,-970 # 80008640 <syscalls+0x208>
    80003a12:	00002097          	auipc	ra,0x2
    80003a16:	46c080e7          	jalr	1132(ra) # 80005e7e <panic>
  log.lh.block[i] = b->blockno;
    80003a1a:	00878713          	addi	a4,a5,8
    80003a1e:	00271693          	slli	a3,a4,0x2
    80003a22:	00115717          	auipc	a4,0x115
    80003a26:	03e70713          	addi	a4,a4,62 # 80118a60 <log>
    80003a2a:	9736                	add	a4,a4,a3
    80003a2c:	44d4                	lw	a3,12(s1)
    80003a2e:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003a30:	faf608e3          	beq	a2,a5,800039e0 <log_write+0x76>
  }
  release(&log.lock);
    80003a34:	00115517          	auipc	a0,0x115
    80003a38:	02c50513          	addi	a0,a0,44 # 80118a60 <log>
    80003a3c:	00003097          	auipc	ra,0x3
    80003a40:	a32080e7          	jalr	-1486(ra) # 8000646e <release>
}
    80003a44:	60e2                	ld	ra,24(sp)
    80003a46:	6442                	ld	s0,16(sp)
    80003a48:	64a2                	ld	s1,8(sp)
    80003a4a:	6902                	ld	s2,0(sp)
    80003a4c:	6105                	addi	sp,sp,32
    80003a4e:	8082                	ret

0000000080003a50 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003a50:	1101                	addi	sp,sp,-32
    80003a52:	ec06                	sd	ra,24(sp)
    80003a54:	e822                	sd	s0,16(sp)
    80003a56:	e426                	sd	s1,8(sp)
    80003a58:	e04a                	sd	s2,0(sp)
    80003a5a:	1000                	addi	s0,sp,32
    80003a5c:	84aa                	mv	s1,a0
    80003a5e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003a60:	00005597          	auipc	a1,0x5
    80003a64:	c0058593          	addi	a1,a1,-1024 # 80008660 <syscalls+0x228>
    80003a68:	0521                	addi	a0,a0,8
    80003a6a:	00003097          	auipc	ra,0x3
    80003a6e:	8c0080e7          	jalr	-1856(ra) # 8000632a <initlock>
  lk->name = name;
    80003a72:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003a76:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003a7a:	0204a423          	sw	zero,40(s1)
}
    80003a7e:	60e2                	ld	ra,24(sp)
    80003a80:	6442                	ld	s0,16(sp)
    80003a82:	64a2                	ld	s1,8(sp)
    80003a84:	6902                	ld	s2,0(sp)
    80003a86:	6105                	addi	sp,sp,32
    80003a88:	8082                	ret

0000000080003a8a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003a8a:	1101                	addi	sp,sp,-32
    80003a8c:	ec06                	sd	ra,24(sp)
    80003a8e:	e822                	sd	s0,16(sp)
    80003a90:	e426                	sd	s1,8(sp)
    80003a92:	e04a                	sd	s2,0(sp)
    80003a94:	1000                	addi	s0,sp,32
    80003a96:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003a98:	00850913          	addi	s2,a0,8
    80003a9c:	854a                	mv	a0,s2
    80003a9e:	00003097          	auipc	ra,0x3
    80003aa2:	91c080e7          	jalr	-1764(ra) # 800063ba <acquire>
  while (lk->locked) {
    80003aa6:	409c                	lw	a5,0(s1)
    80003aa8:	cb89                	beqz	a5,80003aba <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80003aaa:	85ca                	mv	a1,s2
    80003aac:	8526                	mv	a0,s1
    80003aae:	ffffe097          	auipc	ra,0xffffe
    80003ab2:	ce8080e7          	jalr	-792(ra) # 80001796 <sleep>
  while (lk->locked) {
    80003ab6:	409c                	lw	a5,0(s1)
    80003ab8:	fbed                	bnez	a5,80003aaa <acquiresleep+0x20>
  }
  lk->locked = 1;
    80003aba:	4785                	li	a5,1
    80003abc:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003abe:	ffffd097          	auipc	ra,0xffffd
    80003ac2:	62c080e7          	jalr	1580(ra) # 800010ea <myproc>
    80003ac6:	591c                	lw	a5,48(a0)
    80003ac8:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003aca:	854a                	mv	a0,s2
    80003acc:	00003097          	auipc	ra,0x3
    80003ad0:	9a2080e7          	jalr	-1630(ra) # 8000646e <release>
}
    80003ad4:	60e2                	ld	ra,24(sp)
    80003ad6:	6442                	ld	s0,16(sp)
    80003ad8:	64a2                	ld	s1,8(sp)
    80003ada:	6902                	ld	s2,0(sp)
    80003adc:	6105                	addi	sp,sp,32
    80003ade:	8082                	ret

0000000080003ae0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003ae0:	1101                	addi	sp,sp,-32
    80003ae2:	ec06                	sd	ra,24(sp)
    80003ae4:	e822                	sd	s0,16(sp)
    80003ae6:	e426                	sd	s1,8(sp)
    80003ae8:	e04a                	sd	s2,0(sp)
    80003aea:	1000                	addi	s0,sp,32
    80003aec:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003aee:	00850913          	addi	s2,a0,8
    80003af2:	854a                	mv	a0,s2
    80003af4:	00003097          	auipc	ra,0x3
    80003af8:	8c6080e7          	jalr	-1850(ra) # 800063ba <acquire>
  lk->locked = 0;
    80003afc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003b00:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003b04:	8526                	mv	a0,s1
    80003b06:	ffffe097          	auipc	ra,0xffffe
    80003b0a:	cf4080e7          	jalr	-780(ra) # 800017fa <wakeup>
  release(&lk->lk);
    80003b0e:	854a                	mv	a0,s2
    80003b10:	00003097          	auipc	ra,0x3
    80003b14:	95e080e7          	jalr	-1698(ra) # 8000646e <release>
}
    80003b18:	60e2                	ld	ra,24(sp)
    80003b1a:	6442                	ld	s0,16(sp)
    80003b1c:	64a2                	ld	s1,8(sp)
    80003b1e:	6902                	ld	s2,0(sp)
    80003b20:	6105                	addi	sp,sp,32
    80003b22:	8082                	ret

0000000080003b24 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003b24:	7179                	addi	sp,sp,-48
    80003b26:	f406                	sd	ra,40(sp)
    80003b28:	f022                	sd	s0,32(sp)
    80003b2a:	ec26                	sd	s1,24(sp)
    80003b2c:	e84a                	sd	s2,16(sp)
    80003b2e:	e44e                	sd	s3,8(sp)
    80003b30:	1800                	addi	s0,sp,48
    80003b32:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003b34:	00850913          	addi	s2,a0,8
    80003b38:	854a                	mv	a0,s2
    80003b3a:	00003097          	auipc	ra,0x3
    80003b3e:	880080e7          	jalr	-1920(ra) # 800063ba <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003b42:	409c                	lw	a5,0(s1)
    80003b44:	ef99                	bnez	a5,80003b62 <holdingsleep+0x3e>
    80003b46:	4481                	li	s1,0
  release(&lk->lk);
    80003b48:	854a                	mv	a0,s2
    80003b4a:	00003097          	auipc	ra,0x3
    80003b4e:	924080e7          	jalr	-1756(ra) # 8000646e <release>
  return r;
}
    80003b52:	8526                	mv	a0,s1
    80003b54:	70a2                	ld	ra,40(sp)
    80003b56:	7402                	ld	s0,32(sp)
    80003b58:	64e2                	ld	s1,24(sp)
    80003b5a:	6942                	ld	s2,16(sp)
    80003b5c:	69a2                	ld	s3,8(sp)
    80003b5e:	6145                	addi	sp,sp,48
    80003b60:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80003b62:	0284a983          	lw	s3,40(s1)
    80003b66:	ffffd097          	auipc	ra,0xffffd
    80003b6a:	584080e7          	jalr	1412(ra) # 800010ea <myproc>
    80003b6e:	5904                	lw	s1,48(a0)
    80003b70:	413484b3          	sub	s1,s1,s3
    80003b74:	0014b493          	seqz	s1,s1
    80003b78:	bfc1                	j	80003b48 <holdingsleep+0x24>

0000000080003b7a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003b7a:	1141                	addi	sp,sp,-16
    80003b7c:	e406                	sd	ra,8(sp)
    80003b7e:	e022                	sd	s0,0(sp)
    80003b80:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003b82:	00005597          	auipc	a1,0x5
    80003b86:	aee58593          	addi	a1,a1,-1298 # 80008670 <syscalls+0x238>
    80003b8a:	00115517          	auipc	a0,0x115
    80003b8e:	01e50513          	addi	a0,a0,30 # 80118ba8 <ftable>
    80003b92:	00002097          	auipc	ra,0x2
    80003b96:	798080e7          	jalr	1944(ra) # 8000632a <initlock>
}
    80003b9a:	60a2                	ld	ra,8(sp)
    80003b9c:	6402                	ld	s0,0(sp)
    80003b9e:	0141                	addi	sp,sp,16
    80003ba0:	8082                	ret

0000000080003ba2 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003ba2:	1101                	addi	sp,sp,-32
    80003ba4:	ec06                	sd	ra,24(sp)
    80003ba6:	e822                	sd	s0,16(sp)
    80003ba8:	e426                	sd	s1,8(sp)
    80003baa:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003bac:	00115517          	auipc	a0,0x115
    80003bb0:	ffc50513          	addi	a0,a0,-4 # 80118ba8 <ftable>
    80003bb4:	00003097          	auipc	ra,0x3
    80003bb8:	806080e7          	jalr	-2042(ra) # 800063ba <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003bbc:	00115497          	auipc	s1,0x115
    80003bc0:	00448493          	addi	s1,s1,4 # 80118bc0 <ftable+0x18>
    80003bc4:	00116717          	auipc	a4,0x116
    80003bc8:	f9c70713          	addi	a4,a4,-100 # 80119b60 <disk>
    if(f->ref == 0){
    80003bcc:	40dc                	lw	a5,4(s1)
    80003bce:	cf99                	beqz	a5,80003bec <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003bd0:	02848493          	addi	s1,s1,40
    80003bd4:	fee49ce3          	bne	s1,a4,80003bcc <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003bd8:	00115517          	auipc	a0,0x115
    80003bdc:	fd050513          	addi	a0,a0,-48 # 80118ba8 <ftable>
    80003be0:	00003097          	auipc	ra,0x3
    80003be4:	88e080e7          	jalr	-1906(ra) # 8000646e <release>
  return 0;
    80003be8:	4481                	li	s1,0
    80003bea:	a819                	j	80003c00 <filealloc+0x5e>
      f->ref = 1;
    80003bec:	4785                	li	a5,1
    80003bee:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003bf0:	00115517          	auipc	a0,0x115
    80003bf4:	fb850513          	addi	a0,a0,-72 # 80118ba8 <ftable>
    80003bf8:	00003097          	auipc	ra,0x3
    80003bfc:	876080e7          	jalr	-1930(ra) # 8000646e <release>
}
    80003c00:	8526                	mv	a0,s1
    80003c02:	60e2                	ld	ra,24(sp)
    80003c04:	6442                	ld	s0,16(sp)
    80003c06:	64a2                	ld	s1,8(sp)
    80003c08:	6105                	addi	sp,sp,32
    80003c0a:	8082                	ret

0000000080003c0c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003c0c:	1101                	addi	sp,sp,-32
    80003c0e:	ec06                	sd	ra,24(sp)
    80003c10:	e822                	sd	s0,16(sp)
    80003c12:	e426                	sd	s1,8(sp)
    80003c14:	1000                	addi	s0,sp,32
    80003c16:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003c18:	00115517          	auipc	a0,0x115
    80003c1c:	f9050513          	addi	a0,a0,-112 # 80118ba8 <ftable>
    80003c20:	00002097          	auipc	ra,0x2
    80003c24:	79a080e7          	jalr	1946(ra) # 800063ba <acquire>
  if(f->ref < 1)
    80003c28:	40dc                	lw	a5,4(s1)
    80003c2a:	02f05263          	blez	a5,80003c4e <filedup+0x42>
    panic("filedup");
  f->ref++;
    80003c2e:	2785                	addiw	a5,a5,1
    80003c30:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003c32:	00115517          	auipc	a0,0x115
    80003c36:	f7650513          	addi	a0,a0,-138 # 80118ba8 <ftable>
    80003c3a:	00003097          	auipc	ra,0x3
    80003c3e:	834080e7          	jalr	-1996(ra) # 8000646e <release>
  return f;
}
    80003c42:	8526                	mv	a0,s1
    80003c44:	60e2                	ld	ra,24(sp)
    80003c46:	6442                	ld	s0,16(sp)
    80003c48:	64a2                	ld	s1,8(sp)
    80003c4a:	6105                	addi	sp,sp,32
    80003c4c:	8082                	ret
    panic("filedup");
    80003c4e:	00005517          	auipc	a0,0x5
    80003c52:	a2a50513          	addi	a0,a0,-1494 # 80008678 <syscalls+0x240>
    80003c56:	00002097          	auipc	ra,0x2
    80003c5a:	228080e7          	jalr	552(ra) # 80005e7e <panic>

0000000080003c5e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003c5e:	7139                	addi	sp,sp,-64
    80003c60:	fc06                	sd	ra,56(sp)
    80003c62:	f822                	sd	s0,48(sp)
    80003c64:	f426                	sd	s1,40(sp)
    80003c66:	f04a                	sd	s2,32(sp)
    80003c68:	ec4e                	sd	s3,24(sp)
    80003c6a:	e852                	sd	s4,16(sp)
    80003c6c:	e456                	sd	s5,8(sp)
    80003c6e:	0080                	addi	s0,sp,64
    80003c70:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003c72:	00115517          	auipc	a0,0x115
    80003c76:	f3650513          	addi	a0,a0,-202 # 80118ba8 <ftable>
    80003c7a:	00002097          	auipc	ra,0x2
    80003c7e:	740080e7          	jalr	1856(ra) # 800063ba <acquire>
  if(f->ref < 1)
    80003c82:	40dc                	lw	a5,4(s1)
    80003c84:	06f05163          	blez	a5,80003ce6 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80003c88:	37fd                	addiw	a5,a5,-1
    80003c8a:	0007871b          	sext.w	a4,a5
    80003c8e:	c0dc                	sw	a5,4(s1)
    80003c90:	06e04363          	bgtz	a4,80003cf6 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003c94:	0004a903          	lw	s2,0(s1)
    80003c98:	0094ca83          	lbu	s5,9(s1)
    80003c9c:	0104ba03          	ld	s4,16(s1)
    80003ca0:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003ca4:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003ca8:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003cac:	00115517          	auipc	a0,0x115
    80003cb0:	efc50513          	addi	a0,a0,-260 # 80118ba8 <ftable>
    80003cb4:	00002097          	auipc	ra,0x2
    80003cb8:	7ba080e7          	jalr	1978(ra) # 8000646e <release>

  if(ff.type == FD_PIPE){
    80003cbc:	4785                	li	a5,1
    80003cbe:	04f90d63          	beq	s2,a5,80003d18 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003cc2:	3979                	addiw	s2,s2,-2
    80003cc4:	4785                	li	a5,1
    80003cc6:	0527e063          	bltu	a5,s2,80003d06 <fileclose+0xa8>
    begin_op();
    80003cca:	00000097          	auipc	ra,0x0
    80003cce:	ac8080e7          	jalr	-1336(ra) # 80003792 <begin_op>
    iput(ff.ip);
    80003cd2:	854e                	mv	a0,s3
    80003cd4:	fffff097          	auipc	ra,0xfffff
    80003cd8:	2b6080e7          	jalr	694(ra) # 80002f8a <iput>
    end_op();
    80003cdc:	00000097          	auipc	ra,0x0
    80003ce0:	b36080e7          	jalr	-1226(ra) # 80003812 <end_op>
    80003ce4:	a00d                	j	80003d06 <fileclose+0xa8>
    panic("fileclose");
    80003ce6:	00005517          	auipc	a0,0x5
    80003cea:	99a50513          	addi	a0,a0,-1638 # 80008680 <syscalls+0x248>
    80003cee:	00002097          	auipc	ra,0x2
    80003cf2:	190080e7          	jalr	400(ra) # 80005e7e <panic>
    release(&ftable.lock);
    80003cf6:	00115517          	auipc	a0,0x115
    80003cfa:	eb250513          	addi	a0,a0,-334 # 80118ba8 <ftable>
    80003cfe:	00002097          	auipc	ra,0x2
    80003d02:	770080e7          	jalr	1904(ra) # 8000646e <release>
  }
}
    80003d06:	70e2                	ld	ra,56(sp)
    80003d08:	7442                	ld	s0,48(sp)
    80003d0a:	74a2                	ld	s1,40(sp)
    80003d0c:	7902                	ld	s2,32(sp)
    80003d0e:	69e2                	ld	s3,24(sp)
    80003d10:	6a42                	ld	s4,16(sp)
    80003d12:	6aa2                	ld	s5,8(sp)
    80003d14:	6121                	addi	sp,sp,64
    80003d16:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003d18:	85d6                	mv	a1,s5
    80003d1a:	8552                	mv	a0,s4
    80003d1c:	00000097          	auipc	ra,0x0
    80003d20:	34c080e7          	jalr	844(ra) # 80004068 <pipeclose>
    80003d24:	b7cd                	j	80003d06 <fileclose+0xa8>

0000000080003d26 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003d26:	715d                	addi	sp,sp,-80
    80003d28:	e486                	sd	ra,72(sp)
    80003d2a:	e0a2                	sd	s0,64(sp)
    80003d2c:	fc26                	sd	s1,56(sp)
    80003d2e:	f84a                	sd	s2,48(sp)
    80003d30:	f44e                	sd	s3,40(sp)
    80003d32:	0880                	addi	s0,sp,80
    80003d34:	84aa                	mv	s1,a0
    80003d36:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003d38:	ffffd097          	auipc	ra,0xffffd
    80003d3c:	3b2080e7          	jalr	946(ra) # 800010ea <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003d40:	409c                	lw	a5,0(s1)
    80003d42:	37f9                	addiw	a5,a5,-2
    80003d44:	4705                	li	a4,1
    80003d46:	04f76763          	bltu	a4,a5,80003d94 <filestat+0x6e>
    80003d4a:	892a                	mv	s2,a0
    ilock(f->ip);
    80003d4c:	6c88                	ld	a0,24(s1)
    80003d4e:	fffff097          	auipc	ra,0xfffff
    80003d52:	082080e7          	jalr	130(ra) # 80002dd0 <ilock>
    stati(f->ip, &st);
    80003d56:	fb840593          	addi	a1,s0,-72
    80003d5a:	6c88                	ld	a0,24(s1)
    80003d5c:	fffff097          	auipc	ra,0xfffff
    80003d60:	2fe080e7          	jalr	766(ra) # 8000305a <stati>
    iunlock(f->ip);
    80003d64:	6c88                	ld	a0,24(s1)
    80003d66:	fffff097          	auipc	ra,0xfffff
    80003d6a:	12c080e7          	jalr	300(ra) # 80002e92 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80003d6e:	46e1                	li	a3,24
    80003d70:	fb840613          	addi	a2,s0,-72
    80003d74:	85ce                	mv	a1,s3
    80003d76:	05093503          	ld	a0,80(s2)
    80003d7a:	ffffd097          	auipc	ra,0xffffd
    80003d7e:	100080e7          	jalr	256(ra) # 80000e7a <copyout>
    80003d82:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80003d86:	60a6                	ld	ra,72(sp)
    80003d88:	6406                	ld	s0,64(sp)
    80003d8a:	74e2                	ld	s1,56(sp)
    80003d8c:	7942                	ld	s2,48(sp)
    80003d8e:	79a2                	ld	s3,40(sp)
    80003d90:	6161                	addi	sp,sp,80
    80003d92:	8082                	ret
  return -1;
    80003d94:	557d                	li	a0,-1
    80003d96:	bfc5                	j	80003d86 <filestat+0x60>

0000000080003d98 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80003d98:	7179                	addi	sp,sp,-48
    80003d9a:	f406                	sd	ra,40(sp)
    80003d9c:	f022                	sd	s0,32(sp)
    80003d9e:	ec26                	sd	s1,24(sp)
    80003da0:	e84a                	sd	s2,16(sp)
    80003da2:	e44e                	sd	s3,8(sp)
    80003da4:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80003da6:	00854783          	lbu	a5,8(a0)
    80003daa:	c3d5                	beqz	a5,80003e4e <fileread+0xb6>
    80003dac:	84aa                	mv	s1,a0
    80003dae:	89ae                	mv	s3,a1
    80003db0:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80003db2:	411c                	lw	a5,0(a0)
    80003db4:	4705                	li	a4,1
    80003db6:	04e78963          	beq	a5,a4,80003e08 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003dba:	470d                	li	a4,3
    80003dbc:	04e78d63          	beq	a5,a4,80003e16 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80003dc0:	4709                	li	a4,2
    80003dc2:	06e79e63          	bne	a5,a4,80003e3e <fileread+0xa6>
    ilock(f->ip);
    80003dc6:	6d08                	ld	a0,24(a0)
    80003dc8:	fffff097          	auipc	ra,0xfffff
    80003dcc:	008080e7          	jalr	8(ra) # 80002dd0 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80003dd0:	874a                	mv	a4,s2
    80003dd2:	5094                	lw	a3,32(s1)
    80003dd4:	864e                	mv	a2,s3
    80003dd6:	4585                	li	a1,1
    80003dd8:	6c88                	ld	a0,24(s1)
    80003dda:	fffff097          	auipc	ra,0xfffff
    80003dde:	2aa080e7          	jalr	682(ra) # 80003084 <readi>
    80003de2:	892a                	mv	s2,a0
    80003de4:	00a05563          	blez	a0,80003dee <fileread+0x56>
      f->off += r;
    80003de8:	509c                	lw	a5,32(s1)
    80003dea:	9fa9                	addw	a5,a5,a0
    80003dec:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80003dee:	6c88                	ld	a0,24(s1)
    80003df0:	fffff097          	auipc	ra,0xfffff
    80003df4:	0a2080e7          	jalr	162(ra) # 80002e92 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80003df8:	854a                	mv	a0,s2
    80003dfa:	70a2                	ld	ra,40(sp)
    80003dfc:	7402                	ld	s0,32(sp)
    80003dfe:	64e2                	ld	s1,24(sp)
    80003e00:	6942                	ld	s2,16(sp)
    80003e02:	69a2                	ld	s3,8(sp)
    80003e04:	6145                	addi	sp,sp,48
    80003e06:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80003e08:	6908                	ld	a0,16(a0)
    80003e0a:	00000097          	auipc	ra,0x0
    80003e0e:	3c6080e7          	jalr	966(ra) # 800041d0 <piperead>
    80003e12:	892a                	mv	s2,a0
    80003e14:	b7d5                	j	80003df8 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80003e16:	02451783          	lh	a5,36(a0)
    80003e1a:	03079693          	slli	a3,a5,0x30
    80003e1e:	92c1                	srli	a3,a3,0x30
    80003e20:	4725                	li	a4,9
    80003e22:	02d76863          	bltu	a4,a3,80003e52 <fileread+0xba>
    80003e26:	0792                	slli	a5,a5,0x4
    80003e28:	00115717          	auipc	a4,0x115
    80003e2c:	ce070713          	addi	a4,a4,-800 # 80118b08 <devsw>
    80003e30:	97ba                	add	a5,a5,a4
    80003e32:	639c                	ld	a5,0(a5)
    80003e34:	c38d                	beqz	a5,80003e56 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80003e36:	4505                	li	a0,1
    80003e38:	9782                	jalr	a5
    80003e3a:	892a                	mv	s2,a0
    80003e3c:	bf75                	j	80003df8 <fileread+0x60>
    panic("fileread");
    80003e3e:	00005517          	auipc	a0,0x5
    80003e42:	85250513          	addi	a0,a0,-1966 # 80008690 <syscalls+0x258>
    80003e46:	00002097          	auipc	ra,0x2
    80003e4a:	038080e7          	jalr	56(ra) # 80005e7e <panic>
    return -1;
    80003e4e:	597d                	li	s2,-1
    80003e50:	b765                	j	80003df8 <fileread+0x60>
      return -1;
    80003e52:	597d                	li	s2,-1
    80003e54:	b755                	j	80003df8 <fileread+0x60>
    80003e56:	597d                	li	s2,-1
    80003e58:	b745                	j	80003df8 <fileread+0x60>

0000000080003e5a <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80003e5a:	715d                	addi	sp,sp,-80
    80003e5c:	e486                	sd	ra,72(sp)
    80003e5e:	e0a2                	sd	s0,64(sp)
    80003e60:	fc26                	sd	s1,56(sp)
    80003e62:	f84a                	sd	s2,48(sp)
    80003e64:	f44e                	sd	s3,40(sp)
    80003e66:	f052                	sd	s4,32(sp)
    80003e68:	ec56                	sd	s5,24(sp)
    80003e6a:	e85a                	sd	s6,16(sp)
    80003e6c:	e45e                	sd	s7,8(sp)
    80003e6e:	e062                	sd	s8,0(sp)
    80003e70:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80003e72:	00954783          	lbu	a5,9(a0)
    80003e76:	10078663          	beqz	a5,80003f82 <filewrite+0x128>
    80003e7a:	892a                	mv	s2,a0
    80003e7c:	8aae                	mv	s5,a1
    80003e7e:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80003e80:	411c                	lw	a5,0(a0)
    80003e82:	4705                	li	a4,1
    80003e84:	02e78263          	beq	a5,a4,80003ea8 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003e88:	470d                	li	a4,3
    80003e8a:	02e78663          	beq	a5,a4,80003eb6 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80003e8e:	4709                	li	a4,2
    80003e90:	0ee79163          	bne	a5,a4,80003f72 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80003e94:	0ac05d63          	blez	a2,80003f4e <filewrite+0xf4>
    int i = 0;
    80003e98:	4981                	li	s3,0
    80003e9a:	6b05                	lui	s6,0x1
    80003e9c:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80003ea0:	6b85                	lui	s7,0x1
    80003ea2:	c00b8b9b          	addiw	s7,s7,-1024
    80003ea6:	a861                	j	80003f3e <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80003ea8:	6908                	ld	a0,16(a0)
    80003eaa:	00000097          	auipc	ra,0x0
    80003eae:	22e080e7          	jalr	558(ra) # 800040d8 <pipewrite>
    80003eb2:	8a2a                	mv	s4,a0
    80003eb4:	a045                	j	80003f54 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80003eb6:	02451783          	lh	a5,36(a0)
    80003eba:	03079693          	slli	a3,a5,0x30
    80003ebe:	92c1                	srli	a3,a3,0x30
    80003ec0:	4725                	li	a4,9
    80003ec2:	0cd76263          	bltu	a4,a3,80003f86 <filewrite+0x12c>
    80003ec6:	0792                	slli	a5,a5,0x4
    80003ec8:	00115717          	auipc	a4,0x115
    80003ecc:	c4070713          	addi	a4,a4,-960 # 80118b08 <devsw>
    80003ed0:	97ba                	add	a5,a5,a4
    80003ed2:	679c                	ld	a5,8(a5)
    80003ed4:	cbdd                	beqz	a5,80003f8a <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80003ed6:	4505                	li	a0,1
    80003ed8:	9782                	jalr	a5
    80003eda:	8a2a                	mv	s4,a0
    80003edc:	a8a5                	j	80003f54 <filewrite+0xfa>
    80003ede:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80003ee2:	00000097          	auipc	ra,0x0
    80003ee6:	8b0080e7          	jalr	-1872(ra) # 80003792 <begin_op>
      ilock(f->ip);
    80003eea:	01893503          	ld	a0,24(s2)
    80003eee:	fffff097          	auipc	ra,0xfffff
    80003ef2:	ee2080e7          	jalr	-286(ra) # 80002dd0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80003ef6:	8762                	mv	a4,s8
    80003ef8:	02092683          	lw	a3,32(s2)
    80003efc:	01598633          	add	a2,s3,s5
    80003f00:	4585                	li	a1,1
    80003f02:	01893503          	ld	a0,24(s2)
    80003f06:	fffff097          	auipc	ra,0xfffff
    80003f0a:	276080e7          	jalr	630(ra) # 8000317c <writei>
    80003f0e:	84aa                	mv	s1,a0
    80003f10:	00a05763          	blez	a0,80003f1e <filewrite+0xc4>
        f->off += r;
    80003f14:	02092783          	lw	a5,32(s2)
    80003f18:	9fa9                	addw	a5,a5,a0
    80003f1a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80003f1e:	01893503          	ld	a0,24(s2)
    80003f22:	fffff097          	auipc	ra,0xfffff
    80003f26:	f70080e7          	jalr	-144(ra) # 80002e92 <iunlock>
      end_op();
    80003f2a:	00000097          	auipc	ra,0x0
    80003f2e:	8e8080e7          	jalr	-1816(ra) # 80003812 <end_op>

      if(r != n1){
    80003f32:	009c1f63          	bne	s8,s1,80003f50 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80003f36:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80003f3a:	0149db63          	bge	s3,s4,80003f50 <filewrite+0xf6>
      int n1 = n - i;
    80003f3e:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80003f42:	84be                	mv	s1,a5
    80003f44:	2781                	sext.w	a5,a5
    80003f46:	f8fb5ce3          	bge	s6,a5,80003ede <filewrite+0x84>
    80003f4a:	84de                	mv	s1,s7
    80003f4c:	bf49                	j	80003ede <filewrite+0x84>
    int i = 0;
    80003f4e:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80003f50:	013a1f63          	bne	s4,s3,80003f6e <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80003f54:	8552                	mv	a0,s4
    80003f56:	60a6                	ld	ra,72(sp)
    80003f58:	6406                	ld	s0,64(sp)
    80003f5a:	74e2                	ld	s1,56(sp)
    80003f5c:	7942                	ld	s2,48(sp)
    80003f5e:	79a2                	ld	s3,40(sp)
    80003f60:	7a02                	ld	s4,32(sp)
    80003f62:	6ae2                	ld	s5,24(sp)
    80003f64:	6b42                	ld	s6,16(sp)
    80003f66:	6ba2                	ld	s7,8(sp)
    80003f68:	6c02                	ld	s8,0(sp)
    80003f6a:	6161                	addi	sp,sp,80
    80003f6c:	8082                	ret
    ret = (i == n ? n : -1);
    80003f6e:	5a7d                	li	s4,-1
    80003f70:	b7d5                	j	80003f54 <filewrite+0xfa>
    panic("filewrite");
    80003f72:	00004517          	auipc	a0,0x4
    80003f76:	72e50513          	addi	a0,a0,1838 # 800086a0 <syscalls+0x268>
    80003f7a:	00002097          	auipc	ra,0x2
    80003f7e:	f04080e7          	jalr	-252(ra) # 80005e7e <panic>
    return -1;
    80003f82:	5a7d                	li	s4,-1
    80003f84:	bfc1                	j	80003f54 <filewrite+0xfa>
      return -1;
    80003f86:	5a7d                	li	s4,-1
    80003f88:	b7f1                	j	80003f54 <filewrite+0xfa>
    80003f8a:	5a7d                	li	s4,-1
    80003f8c:	b7e1                	j	80003f54 <filewrite+0xfa>

0000000080003f8e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80003f8e:	7179                	addi	sp,sp,-48
    80003f90:	f406                	sd	ra,40(sp)
    80003f92:	f022                	sd	s0,32(sp)
    80003f94:	ec26                	sd	s1,24(sp)
    80003f96:	e84a                	sd	s2,16(sp)
    80003f98:	e44e                	sd	s3,8(sp)
    80003f9a:	e052                	sd	s4,0(sp)
    80003f9c:	1800                	addi	s0,sp,48
    80003f9e:	84aa                	mv	s1,a0
    80003fa0:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80003fa2:	0005b023          	sd	zero,0(a1)
    80003fa6:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80003faa:	00000097          	auipc	ra,0x0
    80003fae:	bf8080e7          	jalr	-1032(ra) # 80003ba2 <filealloc>
    80003fb2:	e088                	sd	a0,0(s1)
    80003fb4:	c551                	beqz	a0,80004040 <pipealloc+0xb2>
    80003fb6:	00000097          	auipc	ra,0x0
    80003fba:	bec080e7          	jalr	-1044(ra) # 80003ba2 <filealloc>
    80003fbe:	00aa3023          	sd	a0,0(s4)
    80003fc2:	c92d                	beqz	a0,80004034 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80003fc4:	ffffc097          	auipc	ra,0xffffc
    80003fc8:	202080e7          	jalr	514(ra) # 800001c6 <kalloc>
    80003fcc:	892a                	mv	s2,a0
    80003fce:	c125                	beqz	a0,8000402e <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80003fd0:	4985                	li	s3,1
    80003fd2:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80003fd6:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80003fda:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80003fde:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80003fe2:	00004597          	auipc	a1,0x4
    80003fe6:	6ce58593          	addi	a1,a1,1742 # 800086b0 <syscalls+0x278>
    80003fea:	00002097          	auipc	ra,0x2
    80003fee:	340080e7          	jalr	832(ra) # 8000632a <initlock>
  (*f0)->type = FD_PIPE;
    80003ff2:	609c                	ld	a5,0(s1)
    80003ff4:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80003ff8:	609c                	ld	a5,0(s1)
    80003ffa:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80003ffe:	609c                	ld	a5,0(s1)
    80004000:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004004:	609c                	ld	a5,0(s1)
    80004006:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000400a:	000a3783          	ld	a5,0(s4)
    8000400e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004012:	000a3783          	ld	a5,0(s4)
    80004016:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000401a:	000a3783          	ld	a5,0(s4)
    8000401e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004022:	000a3783          	ld	a5,0(s4)
    80004026:	0127b823          	sd	s2,16(a5)
  return 0;
    8000402a:	4501                	li	a0,0
    8000402c:	a025                	j	80004054 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000402e:	6088                	ld	a0,0(s1)
    80004030:	e501                	bnez	a0,80004038 <pipealloc+0xaa>
    80004032:	a039                	j	80004040 <pipealloc+0xb2>
    80004034:	6088                	ld	a0,0(s1)
    80004036:	c51d                	beqz	a0,80004064 <pipealloc+0xd6>
    fileclose(*f0);
    80004038:	00000097          	auipc	ra,0x0
    8000403c:	c26080e7          	jalr	-986(ra) # 80003c5e <fileclose>
  if(*f1)
    80004040:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004044:	557d                	li	a0,-1
  if(*f1)
    80004046:	c799                	beqz	a5,80004054 <pipealloc+0xc6>
    fileclose(*f1);
    80004048:	853e                	mv	a0,a5
    8000404a:	00000097          	auipc	ra,0x0
    8000404e:	c14080e7          	jalr	-1004(ra) # 80003c5e <fileclose>
  return -1;
    80004052:	557d                	li	a0,-1
}
    80004054:	70a2                	ld	ra,40(sp)
    80004056:	7402                	ld	s0,32(sp)
    80004058:	64e2                	ld	s1,24(sp)
    8000405a:	6942                	ld	s2,16(sp)
    8000405c:	69a2                	ld	s3,8(sp)
    8000405e:	6a02                	ld	s4,0(sp)
    80004060:	6145                	addi	sp,sp,48
    80004062:	8082                	ret
  return -1;
    80004064:	557d                	li	a0,-1
    80004066:	b7fd                	j	80004054 <pipealloc+0xc6>

0000000080004068 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004068:	1101                	addi	sp,sp,-32
    8000406a:	ec06                	sd	ra,24(sp)
    8000406c:	e822                	sd	s0,16(sp)
    8000406e:	e426                	sd	s1,8(sp)
    80004070:	e04a                	sd	s2,0(sp)
    80004072:	1000                	addi	s0,sp,32
    80004074:	84aa                	mv	s1,a0
    80004076:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004078:	00002097          	auipc	ra,0x2
    8000407c:	342080e7          	jalr	834(ra) # 800063ba <acquire>
  if(writable){
    80004080:	02090d63          	beqz	s2,800040ba <pipeclose+0x52>
    pi->writeopen = 0;
    80004084:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004088:	21848513          	addi	a0,s1,536
    8000408c:	ffffd097          	auipc	ra,0xffffd
    80004090:	76e080e7          	jalr	1902(ra) # 800017fa <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004094:	2204b783          	ld	a5,544(s1)
    80004098:	eb95                	bnez	a5,800040cc <pipeclose+0x64>
    release(&pi->lock);
    8000409a:	8526                	mv	a0,s1
    8000409c:	00002097          	auipc	ra,0x2
    800040a0:	3d2080e7          	jalr	978(ra) # 8000646e <release>
    kfree((char*)pi);
    800040a4:	8526                	mv	a0,s1
    800040a6:	ffffc097          	auipc	ra,0xffffc
    800040aa:	f76080e7          	jalr	-138(ra) # 8000001c <kfree>
  } else
    release(&pi->lock);
}
    800040ae:	60e2                	ld	ra,24(sp)
    800040b0:	6442                	ld	s0,16(sp)
    800040b2:	64a2                	ld	s1,8(sp)
    800040b4:	6902                	ld	s2,0(sp)
    800040b6:	6105                	addi	sp,sp,32
    800040b8:	8082                	ret
    pi->readopen = 0;
    800040ba:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800040be:	21c48513          	addi	a0,s1,540
    800040c2:	ffffd097          	auipc	ra,0xffffd
    800040c6:	738080e7          	jalr	1848(ra) # 800017fa <wakeup>
    800040ca:	b7e9                	j	80004094 <pipeclose+0x2c>
    release(&pi->lock);
    800040cc:	8526                	mv	a0,s1
    800040ce:	00002097          	auipc	ra,0x2
    800040d2:	3a0080e7          	jalr	928(ra) # 8000646e <release>
}
    800040d6:	bfe1                	j	800040ae <pipeclose+0x46>

00000000800040d8 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800040d8:	711d                	addi	sp,sp,-96
    800040da:	ec86                	sd	ra,88(sp)
    800040dc:	e8a2                	sd	s0,80(sp)
    800040de:	e4a6                	sd	s1,72(sp)
    800040e0:	e0ca                	sd	s2,64(sp)
    800040e2:	fc4e                	sd	s3,56(sp)
    800040e4:	f852                	sd	s4,48(sp)
    800040e6:	f456                	sd	s5,40(sp)
    800040e8:	f05a                	sd	s6,32(sp)
    800040ea:	ec5e                	sd	s7,24(sp)
    800040ec:	e862                	sd	s8,16(sp)
    800040ee:	1080                	addi	s0,sp,96
    800040f0:	84aa                	mv	s1,a0
    800040f2:	8aae                	mv	s5,a1
    800040f4:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800040f6:	ffffd097          	auipc	ra,0xffffd
    800040fa:	ff4080e7          	jalr	-12(ra) # 800010ea <myproc>
    800040fe:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004100:	8526                	mv	a0,s1
    80004102:	00002097          	auipc	ra,0x2
    80004106:	2b8080e7          	jalr	696(ra) # 800063ba <acquire>
  while(i < n){
    8000410a:	0b405663          	blez	s4,800041b6 <pipewrite+0xde>
  int i = 0;
    8000410e:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004110:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004112:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004116:	21c48b93          	addi	s7,s1,540
    8000411a:	a089                	j	8000415c <pipewrite+0x84>
      release(&pi->lock);
    8000411c:	8526                	mv	a0,s1
    8000411e:	00002097          	auipc	ra,0x2
    80004122:	350080e7          	jalr	848(ra) # 8000646e <release>
      return -1;
    80004126:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004128:	854a                	mv	a0,s2
    8000412a:	60e6                	ld	ra,88(sp)
    8000412c:	6446                	ld	s0,80(sp)
    8000412e:	64a6                	ld	s1,72(sp)
    80004130:	6906                	ld	s2,64(sp)
    80004132:	79e2                	ld	s3,56(sp)
    80004134:	7a42                	ld	s4,48(sp)
    80004136:	7aa2                	ld	s5,40(sp)
    80004138:	7b02                	ld	s6,32(sp)
    8000413a:	6be2                	ld	s7,24(sp)
    8000413c:	6c42                	ld	s8,16(sp)
    8000413e:	6125                	addi	sp,sp,96
    80004140:	8082                	ret
      wakeup(&pi->nread);
    80004142:	8562                	mv	a0,s8
    80004144:	ffffd097          	auipc	ra,0xffffd
    80004148:	6b6080e7          	jalr	1718(ra) # 800017fa <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000414c:	85a6                	mv	a1,s1
    8000414e:	855e                	mv	a0,s7
    80004150:	ffffd097          	auipc	ra,0xffffd
    80004154:	646080e7          	jalr	1606(ra) # 80001796 <sleep>
  while(i < n){
    80004158:	07495063          	bge	s2,s4,800041b8 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    8000415c:	2204a783          	lw	a5,544(s1)
    80004160:	dfd5                	beqz	a5,8000411c <pipewrite+0x44>
    80004162:	854e                	mv	a0,s3
    80004164:	ffffe097          	auipc	ra,0xffffe
    80004168:	8da080e7          	jalr	-1830(ra) # 80001a3e <killed>
    8000416c:	f945                	bnez	a0,8000411c <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000416e:	2184a783          	lw	a5,536(s1)
    80004172:	21c4a703          	lw	a4,540(s1)
    80004176:	2007879b          	addiw	a5,a5,512
    8000417a:	fcf704e3          	beq	a4,a5,80004142 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000417e:	4685                	li	a3,1
    80004180:	01590633          	add	a2,s2,s5
    80004184:	faf40593          	addi	a1,s0,-81
    80004188:	0509b503          	ld	a0,80(s3)
    8000418c:	ffffd097          	auipc	ra,0xffffd
    80004190:	afa080e7          	jalr	-1286(ra) # 80000c86 <copyin>
    80004194:	03650263          	beq	a0,s6,800041b8 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004198:	21c4a783          	lw	a5,540(s1)
    8000419c:	0017871b          	addiw	a4,a5,1
    800041a0:	20e4ae23          	sw	a4,540(s1)
    800041a4:	1ff7f793          	andi	a5,a5,511
    800041a8:	97a6                	add	a5,a5,s1
    800041aa:	faf44703          	lbu	a4,-81(s0)
    800041ae:	00e78c23          	sb	a4,24(a5)
      i++;
    800041b2:	2905                	addiw	s2,s2,1
    800041b4:	b755                	j	80004158 <pipewrite+0x80>
  int i = 0;
    800041b6:	4901                	li	s2,0
  wakeup(&pi->nread);
    800041b8:	21848513          	addi	a0,s1,536
    800041bc:	ffffd097          	auipc	ra,0xffffd
    800041c0:	63e080e7          	jalr	1598(ra) # 800017fa <wakeup>
  release(&pi->lock);
    800041c4:	8526                	mv	a0,s1
    800041c6:	00002097          	auipc	ra,0x2
    800041ca:	2a8080e7          	jalr	680(ra) # 8000646e <release>
  return i;
    800041ce:	bfa9                	j	80004128 <pipewrite+0x50>

00000000800041d0 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800041d0:	715d                	addi	sp,sp,-80
    800041d2:	e486                	sd	ra,72(sp)
    800041d4:	e0a2                	sd	s0,64(sp)
    800041d6:	fc26                	sd	s1,56(sp)
    800041d8:	f84a                	sd	s2,48(sp)
    800041da:	f44e                	sd	s3,40(sp)
    800041dc:	f052                	sd	s4,32(sp)
    800041de:	ec56                	sd	s5,24(sp)
    800041e0:	e85a                	sd	s6,16(sp)
    800041e2:	0880                	addi	s0,sp,80
    800041e4:	84aa                	mv	s1,a0
    800041e6:	892e                	mv	s2,a1
    800041e8:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800041ea:	ffffd097          	auipc	ra,0xffffd
    800041ee:	f00080e7          	jalr	-256(ra) # 800010ea <myproc>
    800041f2:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800041f4:	8526                	mv	a0,s1
    800041f6:	00002097          	auipc	ra,0x2
    800041fa:	1c4080e7          	jalr	452(ra) # 800063ba <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800041fe:	2184a703          	lw	a4,536(s1)
    80004202:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004206:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000420a:	02f71763          	bne	a4,a5,80004238 <piperead+0x68>
    8000420e:	2244a783          	lw	a5,548(s1)
    80004212:	c39d                	beqz	a5,80004238 <piperead+0x68>
    if(killed(pr)){
    80004214:	8552                	mv	a0,s4
    80004216:	ffffe097          	auipc	ra,0xffffe
    8000421a:	828080e7          	jalr	-2008(ra) # 80001a3e <killed>
    8000421e:	e941                	bnez	a0,800042ae <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004220:	85a6                	mv	a1,s1
    80004222:	854e                	mv	a0,s3
    80004224:	ffffd097          	auipc	ra,0xffffd
    80004228:	572080e7          	jalr	1394(ra) # 80001796 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000422c:	2184a703          	lw	a4,536(s1)
    80004230:	21c4a783          	lw	a5,540(s1)
    80004234:	fcf70de3          	beq	a4,a5,8000420e <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004238:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000423a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000423c:	05505363          	blez	s5,80004282 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004240:	2184a783          	lw	a5,536(s1)
    80004244:	21c4a703          	lw	a4,540(s1)
    80004248:	02f70d63          	beq	a4,a5,80004282 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000424c:	0017871b          	addiw	a4,a5,1
    80004250:	20e4ac23          	sw	a4,536(s1)
    80004254:	1ff7f793          	andi	a5,a5,511
    80004258:	97a6                	add	a5,a5,s1
    8000425a:	0187c783          	lbu	a5,24(a5)
    8000425e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004262:	4685                	li	a3,1
    80004264:	fbf40613          	addi	a2,s0,-65
    80004268:	85ca                	mv	a1,s2
    8000426a:	050a3503          	ld	a0,80(s4)
    8000426e:	ffffd097          	auipc	ra,0xffffd
    80004272:	c0c080e7          	jalr	-1012(ra) # 80000e7a <copyout>
    80004276:	01650663          	beq	a0,s6,80004282 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000427a:	2985                	addiw	s3,s3,1
    8000427c:	0905                	addi	s2,s2,1
    8000427e:	fd3a91e3          	bne	s5,s3,80004240 <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004282:	21c48513          	addi	a0,s1,540
    80004286:	ffffd097          	auipc	ra,0xffffd
    8000428a:	574080e7          	jalr	1396(ra) # 800017fa <wakeup>
  release(&pi->lock);
    8000428e:	8526                	mv	a0,s1
    80004290:	00002097          	auipc	ra,0x2
    80004294:	1de080e7          	jalr	478(ra) # 8000646e <release>
  return i;
}
    80004298:	854e                	mv	a0,s3
    8000429a:	60a6                	ld	ra,72(sp)
    8000429c:	6406                	ld	s0,64(sp)
    8000429e:	74e2                	ld	s1,56(sp)
    800042a0:	7942                	ld	s2,48(sp)
    800042a2:	79a2                	ld	s3,40(sp)
    800042a4:	7a02                	ld	s4,32(sp)
    800042a6:	6ae2                	ld	s5,24(sp)
    800042a8:	6b42                	ld	s6,16(sp)
    800042aa:	6161                	addi	sp,sp,80
    800042ac:	8082                	ret
      release(&pi->lock);
    800042ae:	8526                	mv	a0,s1
    800042b0:	00002097          	auipc	ra,0x2
    800042b4:	1be080e7          	jalr	446(ra) # 8000646e <release>
      return -1;
    800042b8:	59fd                	li	s3,-1
    800042ba:	bff9                	j	80004298 <piperead+0xc8>

00000000800042bc <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800042bc:	1141                	addi	sp,sp,-16
    800042be:	e422                	sd	s0,8(sp)
    800042c0:	0800                	addi	s0,sp,16
    800042c2:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800042c4:	8905                	andi	a0,a0,1
    800042c6:	c111                	beqz	a0,800042ca <flags2perm+0xe>
      perm = PTE_X;
    800042c8:	4521                	li	a0,8
    if(flags & 0x2)
    800042ca:	8b89                	andi	a5,a5,2
    800042cc:	c399                	beqz	a5,800042d2 <flags2perm+0x16>
      perm |= PTE_W;
    800042ce:	00456513          	ori	a0,a0,4
    return perm;
}
    800042d2:	6422                	ld	s0,8(sp)
    800042d4:	0141                	addi	sp,sp,16
    800042d6:	8082                	ret

00000000800042d8 <exec>:

int
exec(char *path, char **argv)
{
    800042d8:	de010113          	addi	sp,sp,-544
    800042dc:	20113c23          	sd	ra,536(sp)
    800042e0:	20813823          	sd	s0,528(sp)
    800042e4:	20913423          	sd	s1,520(sp)
    800042e8:	21213023          	sd	s2,512(sp)
    800042ec:	ffce                	sd	s3,504(sp)
    800042ee:	fbd2                	sd	s4,496(sp)
    800042f0:	f7d6                	sd	s5,488(sp)
    800042f2:	f3da                	sd	s6,480(sp)
    800042f4:	efde                	sd	s7,472(sp)
    800042f6:	ebe2                	sd	s8,464(sp)
    800042f8:	e7e6                	sd	s9,456(sp)
    800042fa:	e3ea                	sd	s10,448(sp)
    800042fc:	ff6e                	sd	s11,440(sp)
    800042fe:	1400                	addi	s0,sp,544
    80004300:	892a                	mv	s2,a0
    80004302:	dea43423          	sd	a0,-536(s0)
    80004306:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000430a:	ffffd097          	auipc	ra,0xffffd
    8000430e:	de0080e7          	jalr	-544(ra) # 800010ea <myproc>
    80004312:	84aa                	mv	s1,a0

  begin_op();
    80004314:	fffff097          	auipc	ra,0xfffff
    80004318:	47e080e7          	jalr	1150(ra) # 80003792 <begin_op>

  if((ip = namei(path)) == 0){
    8000431c:	854a                	mv	a0,s2
    8000431e:	fffff097          	auipc	ra,0xfffff
    80004322:	258080e7          	jalr	600(ra) # 80003576 <namei>
    80004326:	c93d                	beqz	a0,8000439c <exec+0xc4>
    80004328:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000432a:	fffff097          	auipc	ra,0xfffff
    8000432e:	aa6080e7          	jalr	-1370(ra) # 80002dd0 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004332:	04000713          	li	a4,64
    80004336:	4681                	li	a3,0
    80004338:	e5040613          	addi	a2,s0,-432
    8000433c:	4581                	li	a1,0
    8000433e:	8556                	mv	a0,s5
    80004340:	fffff097          	auipc	ra,0xfffff
    80004344:	d44080e7          	jalr	-700(ra) # 80003084 <readi>
    80004348:	04000793          	li	a5,64
    8000434c:	00f51a63          	bne	a0,a5,80004360 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004350:	e5042703          	lw	a4,-432(s0)
    80004354:	464c47b7          	lui	a5,0x464c4
    80004358:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000435c:	04f70663          	beq	a4,a5,800043a8 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004360:	8556                	mv	a0,s5
    80004362:	fffff097          	auipc	ra,0xfffff
    80004366:	cd0080e7          	jalr	-816(ra) # 80003032 <iunlockput>
    end_op();
    8000436a:	fffff097          	auipc	ra,0xfffff
    8000436e:	4a8080e7          	jalr	1192(ra) # 80003812 <end_op>
  }
  return -1;
    80004372:	557d                	li	a0,-1
}
    80004374:	21813083          	ld	ra,536(sp)
    80004378:	21013403          	ld	s0,528(sp)
    8000437c:	20813483          	ld	s1,520(sp)
    80004380:	20013903          	ld	s2,512(sp)
    80004384:	79fe                	ld	s3,504(sp)
    80004386:	7a5e                	ld	s4,496(sp)
    80004388:	7abe                	ld	s5,488(sp)
    8000438a:	7b1e                	ld	s6,480(sp)
    8000438c:	6bfe                	ld	s7,472(sp)
    8000438e:	6c5e                	ld	s8,464(sp)
    80004390:	6cbe                	ld	s9,456(sp)
    80004392:	6d1e                	ld	s10,448(sp)
    80004394:	7dfa                	ld	s11,440(sp)
    80004396:	22010113          	addi	sp,sp,544
    8000439a:	8082                	ret
    end_op();
    8000439c:	fffff097          	auipc	ra,0xfffff
    800043a0:	476080e7          	jalr	1142(ra) # 80003812 <end_op>
    return -1;
    800043a4:	557d                	li	a0,-1
    800043a6:	b7f9                	j	80004374 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    800043a8:	8526                	mv	a0,s1
    800043aa:	ffffd097          	auipc	ra,0xffffd
    800043ae:	e08080e7          	jalr	-504(ra) # 800011b2 <proc_pagetable>
    800043b2:	8b2a                	mv	s6,a0
    800043b4:	d555                	beqz	a0,80004360 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800043b6:	e7042783          	lw	a5,-400(s0)
    800043ba:	e8845703          	lhu	a4,-376(s0)
    800043be:	c735                	beqz	a4,8000442a <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800043c0:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800043c2:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    800043c6:	6a05                	lui	s4,0x1
    800043c8:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800043cc:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    800043d0:	6d85                	lui	s11,0x1
    800043d2:	7d7d                	lui	s10,0xfffff
    800043d4:	a481                	j	80004614 <exec+0x33c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800043d6:	00004517          	auipc	a0,0x4
    800043da:	2e250513          	addi	a0,a0,738 # 800086b8 <syscalls+0x280>
    800043de:	00002097          	auipc	ra,0x2
    800043e2:	aa0080e7          	jalr	-1376(ra) # 80005e7e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800043e6:	874a                	mv	a4,s2
    800043e8:	009c86bb          	addw	a3,s9,s1
    800043ec:	4581                	li	a1,0
    800043ee:	8556                	mv	a0,s5
    800043f0:	fffff097          	auipc	ra,0xfffff
    800043f4:	c94080e7          	jalr	-876(ra) # 80003084 <readi>
    800043f8:	2501                	sext.w	a0,a0
    800043fa:	1aa91a63          	bne	s2,a0,800045ae <exec+0x2d6>
  for(i = 0; i < sz; i += PGSIZE){
    800043fe:	009d84bb          	addw	s1,s11,s1
    80004402:	013d09bb          	addw	s3,s10,s3
    80004406:	1f74f763          	bgeu	s1,s7,800045f4 <exec+0x31c>
    pa = walkaddr(pagetable, va + i);
    8000440a:	02049593          	slli	a1,s1,0x20
    8000440e:	9181                	srli	a1,a1,0x20
    80004410:	95e2                	add	a1,a1,s8
    80004412:	855a                	mv	a0,s6
    80004414:	ffffc097          	auipc	ra,0xffffc
    80004418:	23c080e7          	jalr	572(ra) # 80000650 <walkaddr>
    8000441c:	862a                	mv	a2,a0
    if(pa == 0)
    8000441e:	dd45                	beqz	a0,800043d6 <exec+0xfe>
      n = PGSIZE;
    80004420:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004422:	fd49f2e3          	bgeu	s3,s4,800043e6 <exec+0x10e>
      n = sz - i;
    80004426:	894e                	mv	s2,s3
    80004428:	bf7d                	j	800043e6 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000442a:	4901                	li	s2,0
  iunlockput(ip);
    8000442c:	8556                	mv	a0,s5
    8000442e:	fffff097          	auipc	ra,0xfffff
    80004432:	c04080e7          	jalr	-1020(ra) # 80003032 <iunlockput>
  end_op();
    80004436:	fffff097          	auipc	ra,0xfffff
    8000443a:	3dc080e7          	jalr	988(ra) # 80003812 <end_op>
  p = myproc();
    8000443e:	ffffd097          	auipc	ra,0xffffd
    80004442:	cac080e7          	jalr	-852(ra) # 800010ea <myproc>
    80004446:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004448:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    8000444c:	6785                	lui	a5,0x1
    8000444e:	17fd                	addi	a5,a5,-1
    80004450:	993e                	add	s2,s2,a5
    80004452:	77fd                	lui	a5,0xfffff
    80004454:	00f977b3          	and	a5,s2,a5
    80004458:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    8000445c:	4691                	li	a3,4
    8000445e:	6609                	lui	a2,0x2
    80004460:	963e                	add	a2,a2,a5
    80004462:	85be                	mv	a1,a5
    80004464:	855a                	mv	a0,s6
    80004466:	ffffc097          	auipc	ra,0xffffc
    8000446a:	5c2080e7          	jalr	1474(ra) # 80000a28 <uvmalloc>
    8000446e:	8c2a                	mv	s8,a0
  ip = 0;
    80004470:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004472:	12050e63          	beqz	a0,800045ae <exec+0x2d6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004476:	75f9                	lui	a1,0xffffe
    80004478:	95aa                	add	a1,a1,a0
    8000447a:	855a                	mv	a0,s6
    8000447c:	ffffc097          	auipc	ra,0xffffc
    80004480:	7d8080e7          	jalr	2008(ra) # 80000c54 <uvmclear>
  stackbase = sp - PGSIZE;
    80004484:	7afd                	lui	s5,0xfffff
    80004486:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004488:	df043783          	ld	a5,-528(s0)
    8000448c:	6388                	ld	a0,0(a5)
    8000448e:	c925                	beqz	a0,800044fe <exec+0x226>
    80004490:	e9040993          	addi	s3,s0,-368
    80004494:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004498:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000449a:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000449c:	ffffc097          	auipc	ra,0xffffc
    800044a0:	fa6080e7          	jalr	-90(ra) # 80000442 <strlen>
    800044a4:	0015079b          	addiw	a5,a0,1
    800044a8:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800044ac:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800044b0:	13596663          	bltu	s2,s5,800045dc <exec+0x304>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800044b4:	df043d83          	ld	s11,-528(s0)
    800044b8:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800044bc:	8552                	mv	a0,s4
    800044be:	ffffc097          	auipc	ra,0xffffc
    800044c2:	f84080e7          	jalr	-124(ra) # 80000442 <strlen>
    800044c6:	0015069b          	addiw	a3,a0,1
    800044ca:	8652                	mv	a2,s4
    800044cc:	85ca                	mv	a1,s2
    800044ce:	855a                	mv	a0,s6
    800044d0:	ffffd097          	auipc	ra,0xffffd
    800044d4:	9aa080e7          	jalr	-1622(ra) # 80000e7a <copyout>
    800044d8:	10054663          	bltz	a0,800045e4 <exec+0x30c>
    ustack[argc] = sp;
    800044dc:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800044e0:	0485                	addi	s1,s1,1
    800044e2:	008d8793          	addi	a5,s11,8
    800044e6:	def43823          	sd	a5,-528(s0)
    800044ea:	008db503          	ld	a0,8(s11)
    800044ee:	c911                	beqz	a0,80004502 <exec+0x22a>
    if(argc >= MAXARG)
    800044f0:	09a1                	addi	s3,s3,8
    800044f2:	fb3c95e3          	bne	s9,s3,8000449c <exec+0x1c4>
  sz = sz1;
    800044f6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800044fa:	4a81                	li	s5,0
    800044fc:	a84d                	j	800045ae <exec+0x2d6>
  sp = sz;
    800044fe:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004500:	4481                	li	s1,0
  ustack[argc] = 0;
    80004502:	00349793          	slli	a5,s1,0x3
    80004506:	f9040713          	addi	a4,s0,-112
    8000450a:	97ba                	add	a5,a5,a4
    8000450c:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7fedd020>
  sp -= (argc+1) * sizeof(uint64);
    80004510:	00148693          	addi	a3,s1,1
    80004514:	068e                	slli	a3,a3,0x3
    80004516:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000451a:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    8000451e:	01597663          	bgeu	s2,s5,8000452a <exec+0x252>
  sz = sz1;
    80004522:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004526:	4a81                	li	s5,0
    80004528:	a059                	j	800045ae <exec+0x2d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000452a:	e9040613          	addi	a2,s0,-368
    8000452e:	85ca                	mv	a1,s2
    80004530:	855a                	mv	a0,s6
    80004532:	ffffd097          	auipc	ra,0xffffd
    80004536:	948080e7          	jalr	-1720(ra) # 80000e7a <copyout>
    8000453a:	0a054963          	bltz	a0,800045ec <exec+0x314>
  p->trapframe->a1 = sp;
    8000453e:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80004542:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004546:	de843783          	ld	a5,-536(s0)
    8000454a:	0007c703          	lbu	a4,0(a5)
    8000454e:	cf11                	beqz	a4,8000456a <exec+0x292>
    80004550:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004552:	02f00693          	li	a3,47
    80004556:	a039                	j	80004564 <exec+0x28c>
      last = s+1;
    80004558:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    8000455c:	0785                	addi	a5,a5,1
    8000455e:	fff7c703          	lbu	a4,-1(a5)
    80004562:	c701                	beqz	a4,8000456a <exec+0x292>
    if(*s == '/')
    80004564:	fed71ce3          	bne	a4,a3,8000455c <exec+0x284>
    80004568:	bfc5                	j	80004558 <exec+0x280>
  safestrcpy(p->name, last, sizeof(p->name));
    8000456a:	4641                	li	a2,16
    8000456c:	de843583          	ld	a1,-536(s0)
    80004570:	158b8513          	addi	a0,s7,344
    80004574:	ffffc097          	auipc	ra,0xffffc
    80004578:	e9c080e7          	jalr	-356(ra) # 80000410 <safestrcpy>
  oldpagetable = p->pagetable;
    8000457c:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004580:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004584:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004588:	058bb783          	ld	a5,88(s7)
    8000458c:	e6843703          	ld	a4,-408(s0)
    80004590:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004592:	058bb783          	ld	a5,88(s7)
    80004596:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000459a:	85ea                	mv	a1,s10
    8000459c:	ffffd097          	auipc	ra,0xffffd
    800045a0:	cb2080e7          	jalr	-846(ra) # 8000124e <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800045a4:	0004851b          	sext.w	a0,s1
    800045a8:	b3f1                	j	80004374 <exec+0x9c>
    800045aa:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800045ae:	df843583          	ld	a1,-520(s0)
    800045b2:	855a                	mv	a0,s6
    800045b4:	ffffd097          	auipc	ra,0xffffd
    800045b8:	c9a080e7          	jalr	-870(ra) # 8000124e <proc_freepagetable>
  if(ip){
    800045bc:	da0a92e3          	bnez	s5,80004360 <exec+0x88>
  return -1;
    800045c0:	557d                	li	a0,-1
    800045c2:	bb4d                	j	80004374 <exec+0x9c>
    800045c4:	df243c23          	sd	s2,-520(s0)
    800045c8:	b7dd                	j	800045ae <exec+0x2d6>
    800045ca:	df243c23          	sd	s2,-520(s0)
    800045ce:	b7c5                	j	800045ae <exec+0x2d6>
    800045d0:	df243c23          	sd	s2,-520(s0)
    800045d4:	bfe9                	j	800045ae <exec+0x2d6>
    800045d6:	df243c23          	sd	s2,-520(s0)
    800045da:	bfd1                	j	800045ae <exec+0x2d6>
  sz = sz1;
    800045dc:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800045e0:	4a81                	li	s5,0
    800045e2:	b7f1                	j	800045ae <exec+0x2d6>
  sz = sz1;
    800045e4:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800045e8:	4a81                	li	s5,0
    800045ea:	b7d1                	j	800045ae <exec+0x2d6>
  sz = sz1;
    800045ec:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800045f0:	4a81                	li	s5,0
    800045f2:	bf75                	j	800045ae <exec+0x2d6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800045f4:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800045f8:	e0843783          	ld	a5,-504(s0)
    800045fc:	0017869b          	addiw	a3,a5,1
    80004600:	e0d43423          	sd	a3,-504(s0)
    80004604:	e0043783          	ld	a5,-512(s0)
    80004608:	0387879b          	addiw	a5,a5,56
    8000460c:	e8845703          	lhu	a4,-376(s0)
    80004610:	e0e6dee3          	bge	a3,a4,8000442c <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004614:	2781                	sext.w	a5,a5
    80004616:	e0f43023          	sd	a5,-512(s0)
    8000461a:	03800713          	li	a4,56
    8000461e:	86be                	mv	a3,a5
    80004620:	e1840613          	addi	a2,s0,-488
    80004624:	4581                	li	a1,0
    80004626:	8556                	mv	a0,s5
    80004628:	fffff097          	auipc	ra,0xfffff
    8000462c:	a5c080e7          	jalr	-1444(ra) # 80003084 <readi>
    80004630:	03800793          	li	a5,56
    80004634:	f6f51be3          	bne	a0,a5,800045aa <exec+0x2d2>
    if(ph.type != ELF_PROG_LOAD)
    80004638:	e1842783          	lw	a5,-488(s0)
    8000463c:	4705                	li	a4,1
    8000463e:	fae79de3          	bne	a5,a4,800045f8 <exec+0x320>
    if(ph.memsz < ph.filesz)
    80004642:	e4043483          	ld	s1,-448(s0)
    80004646:	e3843783          	ld	a5,-456(s0)
    8000464a:	f6f4ede3          	bltu	s1,a5,800045c4 <exec+0x2ec>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000464e:	e2843783          	ld	a5,-472(s0)
    80004652:	94be                	add	s1,s1,a5
    80004654:	f6f4ebe3          	bltu	s1,a5,800045ca <exec+0x2f2>
    if(ph.vaddr % PGSIZE != 0)
    80004658:	de043703          	ld	a4,-544(s0)
    8000465c:	8ff9                	and	a5,a5,a4
    8000465e:	fbad                	bnez	a5,800045d0 <exec+0x2f8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004660:	e1c42503          	lw	a0,-484(s0)
    80004664:	00000097          	auipc	ra,0x0
    80004668:	c58080e7          	jalr	-936(ra) # 800042bc <flags2perm>
    8000466c:	86aa                	mv	a3,a0
    8000466e:	8626                	mv	a2,s1
    80004670:	85ca                	mv	a1,s2
    80004672:	855a                	mv	a0,s6
    80004674:	ffffc097          	auipc	ra,0xffffc
    80004678:	3b4080e7          	jalr	948(ra) # 80000a28 <uvmalloc>
    8000467c:	dea43c23          	sd	a0,-520(s0)
    80004680:	d939                	beqz	a0,800045d6 <exec+0x2fe>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004682:	e2843c03          	ld	s8,-472(s0)
    80004686:	e2042c83          	lw	s9,-480(s0)
    8000468a:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000468e:	f60b83e3          	beqz	s7,800045f4 <exec+0x31c>
    80004692:	89de                	mv	s3,s7
    80004694:	4481                	li	s1,0
    80004696:	bb95                	j	8000440a <exec+0x132>

0000000080004698 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004698:	7179                	addi	sp,sp,-48
    8000469a:	f406                	sd	ra,40(sp)
    8000469c:	f022                	sd	s0,32(sp)
    8000469e:	ec26                	sd	s1,24(sp)
    800046a0:	e84a                	sd	s2,16(sp)
    800046a2:	1800                	addi	s0,sp,48
    800046a4:	892e                	mv	s2,a1
    800046a6:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800046a8:	fdc40593          	addi	a1,s0,-36
    800046ac:	ffffe097          	auipc	ra,0xffffe
    800046b0:	baa080e7          	jalr	-1110(ra) # 80002256 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800046b4:	fdc42703          	lw	a4,-36(s0)
    800046b8:	47bd                	li	a5,15
    800046ba:	02e7eb63          	bltu	a5,a4,800046f0 <argfd+0x58>
    800046be:	ffffd097          	auipc	ra,0xffffd
    800046c2:	a2c080e7          	jalr	-1492(ra) # 800010ea <myproc>
    800046c6:	fdc42703          	lw	a4,-36(s0)
    800046ca:	01a70793          	addi	a5,a4,26
    800046ce:	078e                	slli	a5,a5,0x3
    800046d0:	953e                	add	a0,a0,a5
    800046d2:	611c                	ld	a5,0(a0)
    800046d4:	c385                	beqz	a5,800046f4 <argfd+0x5c>
    return -1;
  if(pfd)
    800046d6:	00090463          	beqz	s2,800046de <argfd+0x46>
    *pfd = fd;
    800046da:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800046de:	4501                	li	a0,0
  if(pf)
    800046e0:	c091                	beqz	s1,800046e4 <argfd+0x4c>
    *pf = f;
    800046e2:	e09c                	sd	a5,0(s1)
}
    800046e4:	70a2                	ld	ra,40(sp)
    800046e6:	7402                	ld	s0,32(sp)
    800046e8:	64e2                	ld	s1,24(sp)
    800046ea:	6942                	ld	s2,16(sp)
    800046ec:	6145                	addi	sp,sp,48
    800046ee:	8082                	ret
    return -1;
    800046f0:	557d                	li	a0,-1
    800046f2:	bfcd                	j	800046e4 <argfd+0x4c>
    800046f4:	557d                	li	a0,-1
    800046f6:	b7fd                	j	800046e4 <argfd+0x4c>

00000000800046f8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800046f8:	1101                	addi	sp,sp,-32
    800046fa:	ec06                	sd	ra,24(sp)
    800046fc:	e822                	sd	s0,16(sp)
    800046fe:	e426                	sd	s1,8(sp)
    80004700:	1000                	addi	s0,sp,32
    80004702:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004704:	ffffd097          	auipc	ra,0xffffd
    80004708:	9e6080e7          	jalr	-1562(ra) # 800010ea <myproc>
    8000470c:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000470e:	0d050793          	addi	a5,a0,208
    80004712:	4501                	li	a0,0
    80004714:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004716:	6398                	ld	a4,0(a5)
    80004718:	cb19                	beqz	a4,8000472e <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000471a:	2505                	addiw	a0,a0,1
    8000471c:	07a1                	addi	a5,a5,8
    8000471e:	fed51ce3          	bne	a0,a3,80004716 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004722:	557d                	li	a0,-1
}
    80004724:	60e2                	ld	ra,24(sp)
    80004726:	6442                	ld	s0,16(sp)
    80004728:	64a2                	ld	s1,8(sp)
    8000472a:	6105                	addi	sp,sp,32
    8000472c:	8082                	ret
      p->ofile[fd] = f;
    8000472e:	01a50793          	addi	a5,a0,26
    80004732:	078e                	slli	a5,a5,0x3
    80004734:	963e                	add	a2,a2,a5
    80004736:	e204                	sd	s1,0(a2)
      return fd;
    80004738:	b7f5                	j	80004724 <fdalloc+0x2c>

000000008000473a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000473a:	715d                	addi	sp,sp,-80
    8000473c:	e486                	sd	ra,72(sp)
    8000473e:	e0a2                	sd	s0,64(sp)
    80004740:	fc26                	sd	s1,56(sp)
    80004742:	f84a                	sd	s2,48(sp)
    80004744:	f44e                	sd	s3,40(sp)
    80004746:	f052                	sd	s4,32(sp)
    80004748:	ec56                	sd	s5,24(sp)
    8000474a:	e85a                	sd	s6,16(sp)
    8000474c:	0880                	addi	s0,sp,80
    8000474e:	8b2e                	mv	s6,a1
    80004750:	89b2                	mv	s3,a2
    80004752:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004754:	fb040593          	addi	a1,s0,-80
    80004758:	fffff097          	auipc	ra,0xfffff
    8000475c:	e3c080e7          	jalr	-452(ra) # 80003594 <nameiparent>
    80004760:	84aa                	mv	s1,a0
    80004762:	14050f63          	beqz	a0,800048c0 <create+0x186>
    return 0;

  ilock(dp);
    80004766:	ffffe097          	auipc	ra,0xffffe
    8000476a:	66a080e7          	jalr	1642(ra) # 80002dd0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000476e:	4601                	li	a2,0
    80004770:	fb040593          	addi	a1,s0,-80
    80004774:	8526                	mv	a0,s1
    80004776:	fffff097          	auipc	ra,0xfffff
    8000477a:	b3e080e7          	jalr	-1218(ra) # 800032b4 <dirlookup>
    8000477e:	8aaa                	mv	s5,a0
    80004780:	c931                	beqz	a0,800047d4 <create+0x9a>
    iunlockput(dp);
    80004782:	8526                	mv	a0,s1
    80004784:	fffff097          	auipc	ra,0xfffff
    80004788:	8ae080e7          	jalr	-1874(ra) # 80003032 <iunlockput>
    ilock(ip);
    8000478c:	8556                	mv	a0,s5
    8000478e:	ffffe097          	auipc	ra,0xffffe
    80004792:	642080e7          	jalr	1602(ra) # 80002dd0 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004796:	000b059b          	sext.w	a1,s6
    8000479a:	4789                	li	a5,2
    8000479c:	02f59563          	bne	a1,a5,800047c6 <create+0x8c>
    800047a0:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7fedd164>
    800047a4:	37f9                	addiw	a5,a5,-2
    800047a6:	17c2                	slli	a5,a5,0x30
    800047a8:	93c1                	srli	a5,a5,0x30
    800047aa:	4705                	li	a4,1
    800047ac:	00f76d63          	bltu	a4,a5,800047c6 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800047b0:	8556                	mv	a0,s5
    800047b2:	60a6                	ld	ra,72(sp)
    800047b4:	6406                	ld	s0,64(sp)
    800047b6:	74e2                	ld	s1,56(sp)
    800047b8:	7942                	ld	s2,48(sp)
    800047ba:	79a2                	ld	s3,40(sp)
    800047bc:	7a02                	ld	s4,32(sp)
    800047be:	6ae2                	ld	s5,24(sp)
    800047c0:	6b42                	ld	s6,16(sp)
    800047c2:	6161                	addi	sp,sp,80
    800047c4:	8082                	ret
    iunlockput(ip);
    800047c6:	8556                	mv	a0,s5
    800047c8:	fffff097          	auipc	ra,0xfffff
    800047cc:	86a080e7          	jalr	-1942(ra) # 80003032 <iunlockput>
    return 0;
    800047d0:	4a81                	li	s5,0
    800047d2:	bff9                	j	800047b0 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800047d4:	85da                	mv	a1,s6
    800047d6:	4088                	lw	a0,0(s1)
    800047d8:	ffffe097          	auipc	ra,0xffffe
    800047dc:	45c080e7          	jalr	1116(ra) # 80002c34 <ialloc>
    800047e0:	8a2a                	mv	s4,a0
    800047e2:	c539                	beqz	a0,80004830 <create+0xf6>
  ilock(ip);
    800047e4:	ffffe097          	auipc	ra,0xffffe
    800047e8:	5ec080e7          	jalr	1516(ra) # 80002dd0 <ilock>
  ip->major = major;
    800047ec:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800047f0:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800047f4:	4905                	li	s2,1
    800047f6:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800047fa:	8552                	mv	a0,s4
    800047fc:	ffffe097          	auipc	ra,0xffffe
    80004800:	50a080e7          	jalr	1290(ra) # 80002d06 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004804:	000b059b          	sext.w	a1,s6
    80004808:	03258b63          	beq	a1,s2,8000483e <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    8000480c:	004a2603          	lw	a2,4(s4)
    80004810:	fb040593          	addi	a1,s0,-80
    80004814:	8526                	mv	a0,s1
    80004816:	fffff097          	auipc	ra,0xfffff
    8000481a:	cae080e7          	jalr	-850(ra) # 800034c4 <dirlink>
    8000481e:	06054f63          	bltz	a0,8000489c <create+0x162>
  iunlockput(dp);
    80004822:	8526                	mv	a0,s1
    80004824:	fffff097          	auipc	ra,0xfffff
    80004828:	80e080e7          	jalr	-2034(ra) # 80003032 <iunlockput>
  return ip;
    8000482c:	8ad2                	mv	s5,s4
    8000482e:	b749                	j	800047b0 <create+0x76>
    iunlockput(dp);
    80004830:	8526                	mv	a0,s1
    80004832:	fffff097          	auipc	ra,0xfffff
    80004836:	800080e7          	jalr	-2048(ra) # 80003032 <iunlockput>
    return 0;
    8000483a:	8ad2                	mv	s5,s4
    8000483c:	bf95                	j	800047b0 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000483e:	004a2603          	lw	a2,4(s4)
    80004842:	00004597          	auipc	a1,0x4
    80004846:	e9658593          	addi	a1,a1,-362 # 800086d8 <syscalls+0x2a0>
    8000484a:	8552                	mv	a0,s4
    8000484c:	fffff097          	auipc	ra,0xfffff
    80004850:	c78080e7          	jalr	-904(ra) # 800034c4 <dirlink>
    80004854:	04054463          	bltz	a0,8000489c <create+0x162>
    80004858:	40d0                	lw	a2,4(s1)
    8000485a:	00004597          	auipc	a1,0x4
    8000485e:	e8658593          	addi	a1,a1,-378 # 800086e0 <syscalls+0x2a8>
    80004862:	8552                	mv	a0,s4
    80004864:	fffff097          	auipc	ra,0xfffff
    80004868:	c60080e7          	jalr	-928(ra) # 800034c4 <dirlink>
    8000486c:	02054863          	bltz	a0,8000489c <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    80004870:	004a2603          	lw	a2,4(s4)
    80004874:	fb040593          	addi	a1,s0,-80
    80004878:	8526                	mv	a0,s1
    8000487a:	fffff097          	auipc	ra,0xfffff
    8000487e:	c4a080e7          	jalr	-950(ra) # 800034c4 <dirlink>
    80004882:	00054d63          	bltz	a0,8000489c <create+0x162>
    dp->nlink++;  // for ".."
    80004886:	04a4d783          	lhu	a5,74(s1)
    8000488a:	2785                	addiw	a5,a5,1
    8000488c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004890:	8526                	mv	a0,s1
    80004892:	ffffe097          	auipc	ra,0xffffe
    80004896:	474080e7          	jalr	1140(ra) # 80002d06 <iupdate>
    8000489a:	b761                	j	80004822 <create+0xe8>
  ip->nlink = 0;
    8000489c:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800048a0:	8552                	mv	a0,s4
    800048a2:	ffffe097          	auipc	ra,0xffffe
    800048a6:	464080e7          	jalr	1124(ra) # 80002d06 <iupdate>
  iunlockput(ip);
    800048aa:	8552                	mv	a0,s4
    800048ac:	ffffe097          	auipc	ra,0xffffe
    800048b0:	786080e7          	jalr	1926(ra) # 80003032 <iunlockput>
  iunlockput(dp);
    800048b4:	8526                	mv	a0,s1
    800048b6:	ffffe097          	auipc	ra,0xffffe
    800048ba:	77c080e7          	jalr	1916(ra) # 80003032 <iunlockput>
  return 0;
    800048be:	bdcd                	j	800047b0 <create+0x76>
    return 0;
    800048c0:	8aaa                	mv	s5,a0
    800048c2:	b5fd                	j	800047b0 <create+0x76>

00000000800048c4 <sys_dup>:
{
    800048c4:	7179                	addi	sp,sp,-48
    800048c6:	f406                	sd	ra,40(sp)
    800048c8:	f022                	sd	s0,32(sp)
    800048ca:	ec26                	sd	s1,24(sp)
    800048cc:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800048ce:	fd840613          	addi	a2,s0,-40
    800048d2:	4581                	li	a1,0
    800048d4:	4501                	li	a0,0
    800048d6:	00000097          	auipc	ra,0x0
    800048da:	dc2080e7          	jalr	-574(ra) # 80004698 <argfd>
    return -1;
    800048de:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800048e0:	02054363          	bltz	a0,80004906 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800048e4:	fd843503          	ld	a0,-40(s0)
    800048e8:	00000097          	auipc	ra,0x0
    800048ec:	e10080e7          	jalr	-496(ra) # 800046f8 <fdalloc>
    800048f0:	84aa                	mv	s1,a0
    return -1;
    800048f2:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800048f4:	00054963          	bltz	a0,80004906 <sys_dup+0x42>
  filedup(f);
    800048f8:	fd843503          	ld	a0,-40(s0)
    800048fc:	fffff097          	auipc	ra,0xfffff
    80004900:	310080e7          	jalr	784(ra) # 80003c0c <filedup>
  return fd;
    80004904:	87a6                	mv	a5,s1
}
    80004906:	853e                	mv	a0,a5
    80004908:	70a2                	ld	ra,40(sp)
    8000490a:	7402                	ld	s0,32(sp)
    8000490c:	64e2                	ld	s1,24(sp)
    8000490e:	6145                	addi	sp,sp,48
    80004910:	8082                	ret

0000000080004912 <sys_read>:
{
    80004912:	7179                	addi	sp,sp,-48
    80004914:	f406                	sd	ra,40(sp)
    80004916:	f022                	sd	s0,32(sp)
    80004918:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000491a:	fd840593          	addi	a1,s0,-40
    8000491e:	4505                	li	a0,1
    80004920:	ffffe097          	auipc	ra,0xffffe
    80004924:	956080e7          	jalr	-1706(ra) # 80002276 <argaddr>
  argint(2, &n);
    80004928:	fe440593          	addi	a1,s0,-28
    8000492c:	4509                	li	a0,2
    8000492e:	ffffe097          	auipc	ra,0xffffe
    80004932:	928080e7          	jalr	-1752(ra) # 80002256 <argint>
  if(argfd(0, 0, &f) < 0)
    80004936:	fe840613          	addi	a2,s0,-24
    8000493a:	4581                	li	a1,0
    8000493c:	4501                	li	a0,0
    8000493e:	00000097          	auipc	ra,0x0
    80004942:	d5a080e7          	jalr	-678(ra) # 80004698 <argfd>
    80004946:	87aa                	mv	a5,a0
    return -1;
    80004948:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000494a:	0007cc63          	bltz	a5,80004962 <sys_read+0x50>
  return fileread(f, p, n);
    8000494e:	fe442603          	lw	a2,-28(s0)
    80004952:	fd843583          	ld	a1,-40(s0)
    80004956:	fe843503          	ld	a0,-24(s0)
    8000495a:	fffff097          	auipc	ra,0xfffff
    8000495e:	43e080e7          	jalr	1086(ra) # 80003d98 <fileread>
}
    80004962:	70a2                	ld	ra,40(sp)
    80004964:	7402                	ld	s0,32(sp)
    80004966:	6145                	addi	sp,sp,48
    80004968:	8082                	ret

000000008000496a <sys_write>:
{
    8000496a:	7179                	addi	sp,sp,-48
    8000496c:	f406                	sd	ra,40(sp)
    8000496e:	f022                	sd	s0,32(sp)
    80004970:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004972:	fd840593          	addi	a1,s0,-40
    80004976:	4505                	li	a0,1
    80004978:	ffffe097          	auipc	ra,0xffffe
    8000497c:	8fe080e7          	jalr	-1794(ra) # 80002276 <argaddr>
  argint(2, &n);
    80004980:	fe440593          	addi	a1,s0,-28
    80004984:	4509                	li	a0,2
    80004986:	ffffe097          	auipc	ra,0xffffe
    8000498a:	8d0080e7          	jalr	-1840(ra) # 80002256 <argint>
  if(argfd(0, 0, &f) < 0)
    8000498e:	fe840613          	addi	a2,s0,-24
    80004992:	4581                	li	a1,0
    80004994:	4501                	li	a0,0
    80004996:	00000097          	auipc	ra,0x0
    8000499a:	d02080e7          	jalr	-766(ra) # 80004698 <argfd>
    8000499e:	87aa                	mv	a5,a0
    return -1;
    800049a0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800049a2:	0007cc63          	bltz	a5,800049ba <sys_write+0x50>
  return filewrite(f, p, n);
    800049a6:	fe442603          	lw	a2,-28(s0)
    800049aa:	fd843583          	ld	a1,-40(s0)
    800049ae:	fe843503          	ld	a0,-24(s0)
    800049b2:	fffff097          	auipc	ra,0xfffff
    800049b6:	4a8080e7          	jalr	1192(ra) # 80003e5a <filewrite>
}
    800049ba:	70a2                	ld	ra,40(sp)
    800049bc:	7402                	ld	s0,32(sp)
    800049be:	6145                	addi	sp,sp,48
    800049c0:	8082                	ret

00000000800049c2 <sys_close>:
{
    800049c2:	1101                	addi	sp,sp,-32
    800049c4:	ec06                	sd	ra,24(sp)
    800049c6:	e822                	sd	s0,16(sp)
    800049c8:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800049ca:	fe040613          	addi	a2,s0,-32
    800049ce:	fec40593          	addi	a1,s0,-20
    800049d2:	4501                	li	a0,0
    800049d4:	00000097          	auipc	ra,0x0
    800049d8:	cc4080e7          	jalr	-828(ra) # 80004698 <argfd>
    return -1;
    800049dc:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800049de:	02054463          	bltz	a0,80004a06 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800049e2:	ffffc097          	auipc	ra,0xffffc
    800049e6:	708080e7          	jalr	1800(ra) # 800010ea <myproc>
    800049ea:	fec42783          	lw	a5,-20(s0)
    800049ee:	07e9                	addi	a5,a5,26
    800049f0:	078e                	slli	a5,a5,0x3
    800049f2:	97aa                	add	a5,a5,a0
    800049f4:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800049f8:	fe043503          	ld	a0,-32(s0)
    800049fc:	fffff097          	auipc	ra,0xfffff
    80004a00:	262080e7          	jalr	610(ra) # 80003c5e <fileclose>
  return 0;
    80004a04:	4781                	li	a5,0
}
    80004a06:	853e                	mv	a0,a5
    80004a08:	60e2                	ld	ra,24(sp)
    80004a0a:	6442                	ld	s0,16(sp)
    80004a0c:	6105                	addi	sp,sp,32
    80004a0e:	8082                	ret

0000000080004a10 <sys_fstat>:
{
    80004a10:	1101                	addi	sp,sp,-32
    80004a12:	ec06                	sd	ra,24(sp)
    80004a14:	e822                	sd	s0,16(sp)
    80004a16:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004a18:	fe040593          	addi	a1,s0,-32
    80004a1c:	4505                	li	a0,1
    80004a1e:	ffffe097          	auipc	ra,0xffffe
    80004a22:	858080e7          	jalr	-1960(ra) # 80002276 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004a26:	fe840613          	addi	a2,s0,-24
    80004a2a:	4581                	li	a1,0
    80004a2c:	4501                	li	a0,0
    80004a2e:	00000097          	auipc	ra,0x0
    80004a32:	c6a080e7          	jalr	-918(ra) # 80004698 <argfd>
    80004a36:	87aa                	mv	a5,a0
    return -1;
    80004a38:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004a3a:	0007ca63          	bltz	a5,80004a4e <sys_fstat+0x3e>
  return filestat(f, st);
    80004a3e:	fe043583          	ld	a1,-32(s0)
    80004a42:	fe843503          	ld	a0,-24(s0)
    80004a46:	fffff097          	auipc	ra,0xfffff
    80004a4a:	2e0080e7          	jalr	736(ra) # 80003d26 <filestat>
}
    80004a4e:	60e2                	ld	ra,24(sp)
    80004a50:	6442                	ld	s0,16(sp)
    80004a52:	6105                	addi	sp,sp,32
    80004a54:	8082                	ret

0000000080004a56 <sys_link>:
{
    80004a56:	7169                	addi	sp,sp,-304
    80004a58:	f606                	sd	ra,296(sp)
    80004a5a:	f222                	sd	s0,288(sp)
    80004a5c:	ee26                	sd	s1,280(sp)
    80004a5e:	ea4a                	sd	s2,272(sp)
    80004a60:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004a62:	08000613          	li	a2,128
    80004a66:	ed040593          	addi	a1,s0,-304
    80004a6a:	4501                	li	a0,0
    80004a6c:	ffffe097          	auipc	ra,0xffffe
    80004a70:	82a080e7          	jalr	-2006(ra) # 80002296 <argstr>
    return -1;
    80004a74:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004a76:	10054e63          	bltz	a0,80004b92 <sys_link+0x13c>
    80004a7a:	08000613          	li	a2,128
    80004a7e:	f5040593          	addi	a1,s0,-176
    80004a82:	4505                	li	a0,1
    80004a84:	ffffe097          	auipc	ra,0xffffe
    80004a88:	812080e7          	jalr	-2030(ra) # 80002296 <argstr>
    return -1;
    80004a8c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004a8e:	10054263          	bltz	a0,80004b92 <sys_link+0x13c>
  begin_op();
    80004a92:	fffff097          	auipc	ra,0xfffff
    80004a96:	d00080e7          	jalr	-768(ra) # 80003792 <begin_op>
  if((ip = namei(old)) == 0){
    80004a9a:	ed040513          	addi	a0,s0,-304
    80004a9e:	fffff097          	auipc	ra,0xfffff
    80004aa2:	ad8080e7          	jalr	-1320(ra) # 80003576 <namei>
    80004aa6:	84aa                	mv	s1,a0
    80004aa8:	c551                	beqz	a0,80004b34 <sys_link+0xde>
  ilock(ip);
    80004aaa:	ffffe097          	auipc	ra,0xffffe
    80004aae:	326080e7          	jalr	806(ra) # 80002dd0 <ilock>
  if(ip->type == T_DIR){
    80004ab2:	04449703          	lh	a4,68(s1)
    80004ab6:	4785                	li	a5,1
    80004ab8:	08f70463          	beq	a4,a5,80004b40 <sys_link+0xea>
  ip->nlink++;
    80004abc:	04a4d783          	lhu	a5,74(s1)
    80004ac0:	2785                	addiw	a5,a5,1
    80004ac2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004ac6:	8526                	mv	a0,s1
    80004ac8:	ffffe097          	auipc	ra,0xffffe
    80004acc:	23e080e7          	jalr	574(ra) # 80002d06 <iupdate>
  iunlock(ip);
    80004ad0:	8526                	mv	a0,s1
    80004ad2:	ffffe097          	auipc	ra,0xffffe
    80004ad6:	3c0080e7          	jalr	960(ra) # 80002e92 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004ada:	fd040593          	addi	a1,s0,-48
    80004ade:	f5040513          	addi	a0,s0,-176
    80004ae2:	fffff097          	auipc	ra,0xfffff
    80004ae6:	ab2080e7          	jalr	-1358(ra) # 80003594 <nameiparent>
    80004aea:	892a                	mv	s2,a0
    80004aec:	c935                	beqz	a0,80004b60 <sys_link+0x10a>
  ilock(dp);
    80004aee:	ffffe097          	auipc	ra,0xffffe
    80004af2:	2e2080e7          	jalr	738(ra) # 80002dd0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004af6:	00092703          	lw	a4,0(s2)
    80004afa:	409c                	lw	a5,0(s1)
    80004afc:	04f71d63          	bne	a4,a5,80004b56 <sys_link+0x100>
    80004b00:	40d0                	lw	a2,4(s1)
    80004b02:	fd040593          	addi	a1,s0,-48
    80004b06:	854a                	mv	a0,s2
    80004b08:	fffff097          	auipc	ra,0xfffff
    80004b0c:	9bc080e7          	jalr	-1604(ra) # 800034c4 <dirlink>
    80004b10:	04054363          	bltz	a0,80004b56 <sys_link+0x100>
  iunlockput(dp);
    80004b14:	854a                	mv	a0,s2
    80004b16:	ffffe097          	auipc	ra,0xffffe
    80004b1a:	51c080e7          	jalr	1308(ra) # 80003032 <iunlockput>
  iput(ip);
    80004b1e:	8526                	mv	a0,s1
    80004b20:	ffffe097          	auipc	ra,0xffffe
    80004b24:	46a080e7          	jalr	1130(ra) # 80002f8a <iput>
  end_op();
    80004b28:	fffff097          	auipc	ra,0xfffff
    80004b2c:	cea080e7          	jalr	-790(ra) # 80003812 <end_op>
  return 0;
    80004b30:	4781                	li	a5,0
    80004b32:	a085                	j	80004b92 <sys_link+0x13c>
    end_op();
    80004b34:	fffff097          	auipc	ra,0xfffff
    80004b38:	cde080e7          	jalr	-802(ra) # 80003812 <end_op>
    return -1;
    80004b3c:	57fd                	li	a5,-1
    80004b3e:	a891                	j	80004b92 <sys_link+0x13c>
    iunlockput(ip);
    80004b40:	8526                	mv	a0,s1
    80004b42:	ffffe097          	auipc	ra,0xffffe
    80004b46:	4f0080e7          	jalr	1264(ra) # 80003032 <iunlockput>
    end_op();
    80004b4a:	fffff097          	auipc	ra,0xfffff
    80004b4e:	cc8080e7          	jalr	-824(ra) # 80003812 <end_op>
    return -1;
    80004b52:	57fd                	li	a5,-1
    80004b54:	a83d                	j	80004b92 <sys_link+0x13c>
    iunlockput(dp);
    80004b56:	854a                	mv	a0,s2
    80004b58:	ffffe097          	auipc	ra,0xffffe
    80004b5c:	4da080e7          	jalr	1242(ra) # 80003032 <iunlockput>
  ilock(ip);
    80004b60:	8526                	mv	a0,s1
    80004b62:	ffffe097          	auipc	ra,0xffffe
    80004b66:	26e080e7          	jalr	622(ra) # 80002dd0 <ilock>
  ip->nlink--;
    80004b6a:	04a4d783          	lhu	a5,74(s1)
    80004b6e:	37fd                	addiw	a5,a5,-1
    80004b70:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004b74:	8526                	mv	a0,s1
    80004b76:	ffffe097          	auipc	ra,0xffffe
    80004b7a:	190080e7          	jalr	400(ra) # 80002d06 <iupdate>
  iunlockput(ip);
    80004b7e:	8526                	mv	a0,s1
    80004b80:	ffffe097          	auipc	ra,0xffffe
    80004b84:	4b2080e7          	jalr	1202(ra) # 80003032 <iunlockput>
  end_op();
    80004b88:	fffff097          	auipc	ra,0xfffff
    80004b8c:	c8a080e7          	jalr	-886(ra) # 80003812 <end_op>
  return -1;
    80004b90:	57fd                	li	a5,-1
}
    80004b92:	853e                	mv	a0,a5
    80004b94:	70b2                	ld	ra,296(sp)
    80004b96:	7412                	ld	s0,288(sp)
    80004b98:	64f2                	ld	s1,280(sp)
    80004b9a:	6952                	ld	s2,272(sp)
    80004b9c:	6155                	addi	sp,sp,304
    80004b9e:	8082                	ret

0000000080004ba0 <sys_unlink>:
{
    80004ba0:	7151                	addi	sp,sp,-240
    80004ba2:	f586                	sd	ra,232(sp)
    80004ba4:	f1a2                	sd	s0,224(sp)
    80004ba6:	eda6                	sd	s1,216(sp)
    80004ba8:	e9ca                	sd	s2,208(sp)
    80004baa:	e5ce                	sd	s3,200(sp)
    80004bac:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004bae:	08000613          	li	a2,128
    80004bb2:	f3040593          	addi	a1,s0,-208
    80004bb6:	4501                	li	a0,0
    80004bb8:	ffffd097          	auipc	ra,0xffffd
    80004bbc:	6de080e7          	jalr	1758(ra) # 80002296 <argstr>
    80004bc0:	18054163          	bltz	a0,80004d42 <sys_unlink+0x1a2>
  begin_op();
    80004bc4:	fffff097          	auipc	ra,0xfffff
    80004bc8:	bce080e7          	jalr	-1074(ra) # 80003792 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004bcc:	fb040593          	addi	a1,s0,-80
    80004bd0:	f3040513          	addi	a0,s0,-208
    80004bd4:	fffff097          	auipc	ra,0xfffff
    80004bd8:	9c0080e7          	jalr	-1600(ra) # 80003594 <nameiparent>
    80004bdc:	84aa                	mv	s1,a0
    80004bde:	c979                	beqz	a0,80004cb4 <sys_unlink+0x114>
  ilock(dp);
    80004be0:	ffffe097          	auipc	ra,0xffffe
    80004be4:	1f0080e7          	jalr	496(ra) # 80002dd0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004be8:	00004597          	auipc	a1,0x4
    80004bec:	af058593          	addi	a1,a1,-1296 # 800086d8 <syscalls+0x2a0>
    80004bf0:	fb040513          	addi	a0,s0,-80
    80004bf4:	ffffe097          	auipc	ra,0xffffe
    80004bf8:	6a6080e7          	jalr	1702(ra) # 8000329a <namecmp>
    80004bfc:	14050a63          	beqz	a0,80004d50 <sys_unlink+0x1b0>
    80004c00:	00004597          	auipc	a1,0x4
    80004c04:	ae058593          	addi	a1,a1,-1312 # 800086e0 <syscalls+0x2a8>
    80004c08:	fb040513          	addi	a0,s0,-80
    80004c0c:	ffffe097          	auipc	ra,0xffffe
    80004c10:	68e080e7          	jalr	1678(ra) # 8000329a <namecmp>
    80004c14:	12050e63          	beqz	a0,80004d50 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004c18:	f2c40613          	addi	a2,s0,-212
    80004c1c:	fb040593          	addi	a1,s0,-80
    80004c20:	8526                	mv	a0,s1
    80004c22:	ffffe097          	auipc	ra,0xffffe
    80004c26:	692080e7          	jalr	1682(ra) # 800032b4 <dirlookup>
    80004c2a:	892a                	mv	s2,a0
    80004c2c:	12050263          	beqz	a0,80004d50 <sys_unlink+0x1b0>
  ilock(ip);
    80004c30:	ffffe097          	auipc	ra,0xffffe
    80004c34:	1a0080e7          	jalr	416(ra) # 80002dd0 <ilock>
  if(ip->nlink < 1)
    80004c38:	04a91783          	lh	a5,74(s2)
    80004c3c:	08f05263          	blez	a5,80004cc0 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004c40:	04491703          	lh	a4,68(s2)
    80004c44:	4785                	li	a5,1
    80004c46:	08f70563          	beq	a4,a5,80004cd0 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80004c4a:	4641                	li	a2,16
    80004c4c:	4581                	li	a1,0
    80004c4e:	fc040513          	addi	a0,s0,-64
    80004c52:	ffffb097          	auipc	ra,0xffffb
    80004c56:	674080e7          	jalr	1652(ra) # 800002c6 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004c5a:	4741                	li	a4,16
    80004c5c:	f2c42683          	lw	a3,-212(s0)
    80004c60:	fc040613          	addi	a2,s0,-64
    80004c64:	4581                	li	a1,0
    80004c66:	8526                	mv	a0,s1
    80004c68:	ffffe097          	auipc	ra,0xffffe
    80004c6c:	514080e7          	jalr	1300(ra) # 8000317c <writei>
    80004c70:	47c1                	li	a5,16
    80004c72:	0af51563          	bne	a0,a5,80004d1c <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80004c76:	04491703          	lh	a4,68(s2)
    80004c7a:	4785                	li	a5,1
    80004c7c:	0af70863          	beq	a4,a5,80004d2c <sys_unlink+0x18c>
  iunlockput(dp);
    80004c80:	8526                	mv	a0,s1
    80004c82:	ffffe097          	auipc	ra,0xffffe
    80004c86:	3b0080e7          	jalr	944(ra) # 80003032 <iunlockput>
  ip->nlink--;
    80004c8a:	04a95783          	lhu	a5,74(s2)
    80004c8e:	37fd                	addiw	a5,a5,-1
    80004c90:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004c94:	854a                	mv	a0,s2
    80004c96:	ffffe097          	auipc	ra,0xffffe
    80004c9a:	070080e7          	jalr	112(ra) # 80002d06 <iupdate>
  iunlockput(ip);
    80004c9e:	854a                	mv	a0,s2
    80004ca0:	ffffe097          	auipc	ra,0xffffe
    80004ca4:	392080e7          	jalr	914(ra) # 80003032 <iunlockput>
  end_op();
    80004ca8:	fffff097          	auipc	ra,0xfffff
    80004cac:	b6a080e7          	jalr	-1174(ra) # 80003812 <end_op>
  return 0;
    80004cb0:	4501                	li	a0,0
    80004cb2:	a84d                	j	80004d64 <sys_unlink+0x1c4>
    end_op();
    80004cb4:	fffff097          	auipc	ra,0xfffff
    80004cb8:	b5e080e7          	jalr	-1186(ra) # 80003812 <end_op>
    return -1;
    80004cbc:	557d                	li	a0,-1
    80004cbe:	a05d                	j	80004d64 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80004cc0:	00004517          	auipc	a0,0x4
    80004cc4:	a2850513          	addi	a0,a0,-1496 # 800086e8 <syscalls+0x2b0>
    80004cc8:	00001097          	auipc	ra,0x1
    80004ccc:	1b6080e7          	jalr	438(ra) # 80005e7e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004cd0:	04c92703          	lw	a4,76(s2)
    80004cd4:	02000793          	li	a5,32
    80004cd8:	f6e7f9e3          	bgeu	a5,a4,80004c4a <sys_unlink+0xaa>
    80004cdc:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004ce0:	4741                	li	a4,16
    80004ce2:	86ce                	mv	a3,s3
    80004ce4:	f1840613          	addi	a2,s0,-232
    80004ce8:	4581                	li	a1,0
    80004cea:	854a                	mv	a0,s2
    80004cec:	ffffe097          	auipc	ra,0xffffe
    80004cf0:	398080e7          	jalr	920(ra) # 80003084 <readi>
    80004cf4:	47c1                	li	a5,16
    80004cf6:	00f51b63          	bne	a0,a5,80004d0c <sys_unlink+0x16c>
    if(de.inum != 0)
    80004cfa:	f1845783          	lhu	a5,-232(s0)
    80004cfe:	e7a1                	bnez	a5,80004d46 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004d00:	29c1                	addiw	s3,s3,16
    80004d02:	04c92783          	lw	a5,76(s2)
    80004d06:	fcf9ede3          	bltu	s3,a5,80004ce0 <sys_unlink+0x140>
    80004d0a:	b781                	j	80004c4a <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80004d0c:	00004517          	auipc	a0,0x4
    80004d10:	9f450513          	addi	a0,a0,-1548 # 80008700 <syscalls+0x2c8>
    80004d14:	00001097          	auipc	ra,0x1
    80004d18:	16a080e7          	jalr	362(ra) # 80005e7e <panic>
    panic("unlink: writei");
    80004d1c:	00004517          	auipc	a0,0x4
    80004d20:	9fc50513          	addi	a0,a0,-1540 # 80008718 <syscalls+0x2e0>
    80004d24:	00001097          	auipc	ra,0x1
    80004d28:	15a080e7          	jalr	346(ra) # 80005e7e <panic>
    dp->nlink--;
    80004d2c:	04a4d783          	lhu	a5,74(s1)
    80004d30:	37fd                	addiw	a5,a5,-1
    80004d32:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004d36:	8526                	mv	a0,s1
    80004d38:	ffffe097          	auipc	ra,0xffffe
    80004d3c:	fce080e7          	jalr	-50(ra) # 80002d06 <iupdate>
    80004d40:	b781                	j	80004c80 <sys_unlink+0xe0>
    return -1;
    80004d42:	557d                	li	a0,-1
    80004d44:	a005                	j	80004d64 <sys_unlink+0x1c4>
    iunlockput(ip);
    80004d46:	854a                	mv	a0,s2
    80004d48:	ffffe097          	auipc	ra,0xffffe
    80004d4c:	2ea080e7          	jalr	746(ra) # 80003032 <iunlockput>
  iunlockput(dp);
    80004d50:	8526                	mv	a0,s1
    80004d52:	ffffe097          	auipc	ra,0xffffe
    80004d56:	2e0080e7          	jalr	736(ra) # 80003032 <iunlockput>
  end_op();
    80004d5a:	fffff097          	auipc	ra,0xfffff
    80004d5e:	ab8080e7          	jalr	-1352(ra) # 80003812 <end_op>
  return -1;
    80004d62:	557d                	li	a0,-1
}
    80004d64:	70ae                	ld	ra,232(sp)
    80004d66:	740e                	ld	s0,224(sp)
    80004d68:	64ee                	ld	s1,216(sp)
    80004d6a:	694e                	ld	s2,208(sp)
    80004d6c:	69ae                	ld	s3,200(sp)
    80004d6e:	616d                	addi	sp,sp,240
    80004d70:	8082                	ret

0000000080004d72 <sys_open>:

uint64
sys_open(void)
{
    80004d72:	7131                	addi	sp,sp,-192
    80004d74:	fd06                	sd	ra,184(sp)
    80004d76:	f922                	sd	s0,176(sp)
    80004d78:	f526                	sd	s1,168(sp)
    80004d7a:	f14a                	sd	s2,160(sp)
    80004d7c:	ed4e                	sd	s3,152(sp)
    80004d7e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004d80:	f4c40593          	addi	a1,s0,-180
    80004d84:	4505                	li	a0,1
    80004d86:	ffffd097          	auipc	ra,0xffffd
    80004d8a:	4d0080e7          	jalr	1232(ra) # 80002256 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004d8e:	08000613          	li	a2,128
    80004d92:	f5040593          	addi	a1,s0,-176
    80004d96:	4501                	li	a0,0
    80004d98:	ffffd097          	auipc	ra,0xffffd
    80004d9c:	4fe080e7          	jalr	1278(ra) # 80002296 <argstr>
    80004da0:	87aa                	mv	a5,a0
    return -1;
    80004da2:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004da4:	0a07c963          	bltz	a5,80004e56 <sys_open+0xe4>

  begin_op();
    80004da8:	fffff097          	auipc	ra,0xfffff
    80004dac:	9ea080e7          	jalr	-1558(ra) # 80003792 <begin_op>

  if(omode & O_CREATE){
    80004db0:	f4c42783          	lw	a5,-180(s0)
    80004db4:	2007f793          	andi	a5,a5,512
    80004db8:	cfc5                	beqz	a5,80004e70 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80004dba:	4681                	li	a3,0
    80004dbc:	4601                	li	a2,0
    80004dbe:	4589                	li	a1,2
    80004dc0:	f5040513          	addi	a0,s0,-176
    80004dc4:	00000097          	auipc	ra,0x0
    80004dc8:	976080e7          	jalr	-1674(ra) # 8000473a <create>
    80004dcc:	84aa                	mv	s1,a0
    if(ip == 0){
    80004dce:	c959                	beqz	a0,80004e64 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004dd0:	04449703          	lh	a4,68(s1)
    80004dd4:	478d                	li	a5,3
    80004dd6:	00f71763          	bne	a4,a5,80004de4 <sys_open+0x72>
    80004dda:	0464d703          	lhu	a4,70(s1)
    80004dde:	47a5                	li	a5,9
    80004de0:	0ce7ed63          	bltu	a5,a4,80004eba <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004de4:	fffff097          	auipc	ra,0xfffff
    80004de8:	dbe080e7          	jalr	-578(ra) # 80003ba2 <filealloc>
    80004dec:	89aa                	mv	s3,a0
    80004dee:	10050363          	beqz	a0,80004ef4 <sys_open+0x182>
    80004df2:	00000097          	auipc	ra,0x0
    80004df6:	906080e7          	jalr	-1786(ra) # 800046f8 <fdalloc>
    80004dfa:	892a                	mv	s2,a0
    80004dfc:	0e054763          	bltz	a0,80004eea <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004e00:	04449703          	lh	a4,68(s1)
    80004e04:	478d                	li	a5,3
    80004e06:	0cf70563          	beq	a4,a5,80004ed0 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004e0a:	4789                	li	a5,2
    80004e0c:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80004e10:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80004e14:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80004e18:	f4c42783          	lw	a5,-180(s0)
    80004e1c:	0017c713          	xori	a4,a5,1
    80004e20:	8b05                	andi	a4,a4,1
    80004e22:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004e26:	0037f713          	andi	a4,a5,3
    80004e2a:	00e03733          	snez	a4,a4
    80004e2e:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004e32:	4007f793          	andi	a5,a5,1024
    80004e36:	c791                	beqz	a5,80004e42 <sys_open+0xd0>
    80004e38:	04449703          	lh	a4,68(s1)
    80004e3c:	4789                	li	a5,2
    80004e3e:	0af70063          	beq	a4,a5,80004ede <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80004e42:	8526                	mv	a0,s1
    80004e44:	ffffe097          	auipc	ra,0xffffe
    80004e48:	04e080e7          	jalr	78(ra) # 80002e92 <iunlock>
  end_op();
    80004e4c:	fffff097          	auipc	ra,0xfffff
    80004e50:	9c6080e7          	jalr	-1594(ra) # 80003812 <end_op>

  return fd;
    80004e54:	854a                	mv	a0,s2
}
    80004e56:	70ea                	ld	ra,184(sp)
    80004e58:	744a                	ld	s0,176(sp)
    80004e5a:	74aa                	ld	s1,168(sp)
    80004e5c:	790a                	ld	s2,160(sp)
    80004e5e:	69ea                	ld	s3,152(sp)
    80004e60:	6129                	addi	sp,sp,192
    80004e62:	8082                	ret
      end_op();
    80004e64:	fffff097          	auipc	ra,0xfffff
    80004e68:	9ae080e7          	jalr	-1618(ra) # 80003812 <end_op>
      return -1;
    80004e6c:	557d                	li	a0,-1
    80004e6e:	b7e5                	j	80004e56 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80004e70:	f5040513          	addi	a0,s0,-176
    80004e74:	ffffe097          	auipc	ra,0xffffe
    80004e78:	702080e7          	jalr	1794(ra) # 80003576 <namei>
    80004e7c:	84aa                	mv	s1,a0
    80004e7e:	c905                	beqz	a0,80004eae <sys_open+0x13c>
    ilock(ip);
    80004e80:	ffffe097          	auipc	ra,0xffffe
    80004e84:	f50080e7          	jalr	-176(ra) # 80002dd0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004e88:	04449703          	lh	a4,68(s1)
    80004e8c:	4785                	li	a5,1
    80004e8e:	f4f711e3          	bne	a4,a5,80004dd0 <sys_open+0x5e>
    80004e92:	f4c42783          	lw	a5,-180(s0)
    80004e96:	d7b9                	beqz	a5,80004de4 <sys_open+0x72>
      iunlockput(ip);
    80004e98:	8526                	mv	a0,s1
    80004e9a:	ffffe097          	auipc	ra,0xffffe
    80004e9e:	198080e7          	jalr	408(ra) # 80003032 <iunlockput>
      end_op();
    80004ea2:	fffff097          	auipc	ra,0xfffff
    80004ea6:	970080e7          	jalr	-1680(ra) # 80003812 <end_op>
      return -1;
    80004eaa:	557d                	li	a0,-1
    80004eac:	b76d                	j	80004e56 <sys_open+0xe4>
      end_op();
    80004eae:	fffff097          	auipc	ra,0xfffff
    80004eb2:	964080e7          	jalr	-1692(ra) # 80003812 <end_op>
      return -1;
    80004eb6:	557d                	li	a0,-1
    80004eb8:	bf79                	j	80004e56 <sys_open+0xe4>
    iunlockput(ip);
    80004eba:	8526                	mv	a0,s1
    80004ebc:	ffffe097          	auipc	ra,0xffffe
    80004ec0:	176080e7          	jalr	374(ra) # 80003032 <iunlockput>
    end_op();
    80004ec4:	fffff097          	auipc	ra,0xfffff
    80004ec8:	94e080e7          	jalr	-1714(ra) # 80003812 <end_op>
    return -1;
    80004ecc:	557d                	li	a0,-1
    80004ece:	b761                	j	80004e56 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80004ed0:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80004ed4:	04649783          	lh	a5,70(s1)
    80004ed8:	02f99223          	sh	a5,36(s3)
    80004edc:	bf25                	j	80004e14 <sys_open+0xa2>
    itrunc(ip);
    80004ede:	8526                	mv	a0,s1
    80004ee0:	ffffe097          	auipc	ra,0xffffe
    80004ee4:	ffe080e7          	jalr	-2(ra) # 80002ede <itrunc>
    80004ee8:	bfa9                	j	80004e42 <sys_open+0xd0>
      fileclose(f);
    80004eea:	854e                	mv	a0,s3
    80004eec:	fffff097          	auipc	ra,0xfffff
    80004ef0:	d72080e7          	jalr	-654(ra) # 80003c5e <fileclose>
    iunlockput(ip);
    80004ef4:	8526                	mv	a0,s1
    80004ef6:	ffffe097          	auipc	ra,0xffffe
    80004efa:	13c080e7          	jalr	316(ra) # 80003032 <iunlockput>
    end_op();
    80004efe:	fffff097          	auipc	ra,0xfffff
    80004f02:	914080e7          	jalr	-1772(ra) # 80003812 <end_op>
    return -1;
    80004f06:	557d                	li	a0,-1
    80004f08:	b7b9                	j	80004e56 <sys_open+0xe4>

0000000080004f0a <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004f0a:	7175                	addi	sp,sp,-144
    80004f0c:	e506                	sd	ra,136(sp)
    80004f0e:	e122                	sd	s0,128(sp)
    80004f10:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004f12:	fffff097          	auipc	ra,0xfffff
    80004f16:	880080e7          	jalr	-1920(ra) # 80003792 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004f1a:	08000613          	li	a2,128
    80004f1e:	f7040593          	addi	a1,s0,-144
    80004f22:	4501                	li	a0,0
    80004f24:	ffffd097          	auipc	ra,0xffffd
    80004f28:	372080e7          	jalr	882(ra) # 80002296 <argstr>
    80004f2c:	02054963          	bltz	a0,80004f5e <sys_mkdir+0x54>
    80004f30:	4681                	li	a3,0
    80004f32:	4601                	li	a2,0
    80004f34:	4585                	li	a1,1
    80004f36:	f7040513          	addi	a0,s0,-144
    80004f3a:	00000097          	auipc	ra,0x0
    80004f3e:	800080e7          	jalr	-2048(ra) # 8000473a <create>
    80004f42:	cd11                	beqz	a0,80004f5e <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004f44:	ffffe097          	auipc	ra,0xffffe
    80004f48:	0ee080e7          	jalr	238(ra) # 80003032 <iunlockput>
  end_op();
    80004f4c:	fffff097          	auipc	ra,0xfffff
    80004f50:	8c6080e7          	jalr	-1850(ra) # 80003812 <end_op>
  return 0;
    80004f54:	4501                	li	a0,0
}
    80004f56:	60aa                	ld	ra,136(sp)
    80004f58:	640a                	ld	s0,128(sp)
    80004f5a:	6149                	addi	sp,sp,144
    80004f5c:	8082                	ret
    end_op();
    80004f5e:	fffff097          	auipc	ra,0xfffff
    80004f62:	8b4080e7          	jalr	-1868(ra) # 80003812 <end_op>
    return -1;
    80004f66:	557d                	li	a0,-1
    80004f68:	b7fd                	j	80004f56 <sys_mkdir+0x4c>

0000000080004f6a <sys_mknod>:

uint64
sys_mknod(void)
{
    80004f6a:	7135                	addi	sp,sp,-160
    80004f6c:	ed06                	sd	ra,152(sp)
    80004f6e:	e922                	sd	s0,144(sp)
    80004f70:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004f72:	fffff097          	auipc	ra,0xfffff
    80004f76:	820080e7          	jalr	-2016(ra) # 80003792 <begin_op>
  argint(1, &major);
    80004f7a:	f6c40593          	addi	a1,s0,-148
    80004f7e:	4505                	li	a0,1
    80004f80:	ffffd097          	auipc	ra,0xffffd
    80004f84:	2d6080e7          	jalr	726(ra) # 80002256 <argint>
  argint(2, &minor);
    80004f88:	f6840593          	addi	a1,s0,-152
    80004f8c:	4509                	li	a0,2
    80004f8e:	ffffd097          	auipc	ra,0xffffd
    80004f92:	2c8080e7          	jalr	712(ra) # 80002256 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004f96:	08000613          	li	a2,128
    80004f9a:	f7040593          	addi	a1,s0,-144
    80004f9e:	4501                	li	a0,0
    80004fa0:	ffffd097          	auipc	ra,0xffffd
    80004fa4:	2f6080e7          	jalr	758(ra) # 80002296 <argstr>
    80004fa8:	02054b63          	bltz	a0,80004fde <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004fac:	f6841683          	lh	a3,-152(s0)
    80004fb0:	f6c41603          	lh	a2,-148(s0)
    80004fb4:	458d                	li	a1,3
    80004fb6:	f7040513          	addi	a0,s0,-144
    80004fba:	fffff097          	auipc	ra,0xfffff
    80004fbe:	780080e7          	jalr	1920(ra) # 8000473a <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004fc2:	cd11                	beqz	a0,80004fde <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004fc4:	ffffe097          	auipc	ra,0xffffe
    80004fc8:	06e080e7          	jalr	110(ra) # 80003032 <iunlockput>
  end_op();
    80004fcc:	fffff097          	auipc	ra,0xfffff
    80004fd0:	846080e7          	jalr	-1978(ra) # 80003812 <end_op>
  return 0;
    80004fd4:	4501                	li	a0,0
}
    80004fd6:	60ea                	ld	ra,152(sp)
    80004fd8:	644a                	ld	s0,144(sp)
    80004fda:	610d                	addi	sp,sp,160
    80004fdc:	8082                	ret
    end_op();
    80004fde:	fffff097          	auipc	ra,0xfffff
    80004fe2:	834080e7          	jalr	-1996(ra) # 80003812 <end_op>
    return -1;
    80004fe6:	557d                	li	a0,-1
    80004fe8:	b7fd                	j	80004fd6 <sys_mknod+0x6c>

0000000080004fea <sys_chdir>:

uint64
sys_chdir(void)
{
    80004fea:	7135                	addi	sp,sp,-160
    80004fec:	ed06                	sd	ra,152(sp)
    80004fee:	e922                	sd	s0,144(sp)
    80004ff0:	e526                	sd	s1,136(sp)
    80004ff2:	e14a                	sd	s2,128(sp)
    80004ff4:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80004ff6:	ffffc097          	auipc	ra,0xffffc
    80004ffa:	0f4080e7          	jalr	244(ra) # 800010ea <myproc>
    80004ffe:	892a                	mv	s2,a0
  
  begin_op();
    80005000:	ffffe097          	auipc	ra,0xffffe
    80005004:	792080e7          	jalr	1938(ra) # 80003792 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005008:	08000613          	li	a2,128
    8000500c:	f6040593          	addi	a1,s0,-160
    80005010:	4501                	li	a0,0
    80005012:	ffffd097          	auipc	ra,0xffffd
    80005016:	284080e7          	jalr	644(ra) # 80002296 <argstr>
    8000501a:	04054b63          	bltz	a0,80005070 <sys_chdir+0x86>
    8000501e:	f6040513          	addi	a0,s0,-160
    80005022:	ffffe097          	auipc	ra,0xffffe
    80005026:	554080e7          	jalr	1364(ra) # 80003576 <namei>
    8000502a:	84aa                	mv	s1,a0
    8000502c:	c131                	beqz	a0,80005070 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    8000502e:	ffffe097          	auipc	ra,0xffffe
    80005032:	da2080e7          	jalr	-606(ra) # 80002dd0 <ilock>
  if(ip->type != T_DIR){
    80005036:	04449703          	lh	a4,68(s1)
    8000503a:	4785                	li	a5,1
    8000503c:	04f71063          	bne	a4,a5,8000507c <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005040:	8526                	mv	a0,s1
    80005042:	ffffe097          	auipc	ra,0xffffe
    80005046:	e50080e7          	jalr	-432(ra) # 80002e92 <iunlock>
  iput(p->cwd);
    8000504a:	15093503          	ld	a0,336(s2)
    8000504e:	ffffe097          	auipc	ra,0xffffe
    80005052:	f3c080e7          	jalr	-196(ra) # 80002f8a <iput>
  end_op();
    80005056:	ffffe097          	auipc	ra,0xffffe
    8000505a:	7bc080e7          	jalr	1980(ra) # 80003812 <end_op>
  p->cwd = ip;
    8000505e:	14993823          	sd	s1,336(s2)
  return 0;
    80005062:	4501                	li	a0,0
}
    80005064:	60ea                	ld	ra,152(sp)
    80005066:	644a                	ld	s0,144(sp)
    80005068:	64aa                	ld	s1,136(sp)
    8000506a:	690a                	ld	s2,128(sp)
    8000506c:	610d                	addi	sp,sp,160
    8000506e:	8082                	ret
    end_op();
    80005070:	ffffe097          	auipc	ra,0xffffe
    80005074:	7a2080e7          	jalr	1954(ra) # 80003812 <end_op>
    return -1;
    80005078:	557d                	li	a0,-1
    8000507a:	b7ed                	j	80005064 <sys_chdir+0x7a>
    iunlockput(ip);
    8000507c:	8526                	mv	a0,s1
    8000507e:	ffffe097          	auipc	ra,0xffffe
    80005082:	fb4080e7          	jalr	-76(ra) # 80003032 <iunlockput>
    end_op();
    80005086:	ffffe097          	auipc	ra,0xffffe
    8000508a:	78c080e7          	jalr	1932(ra) # 80003812 <end_op>
    return -1;
    8000508e:	557d                	li	a0,-1
    80005090:	bfd1                	j	80005064 <sys_chdir+0x7a>

0000000080005092 <sys_exec>:

uint64
sys_exec(void)
{
    80005092:	7145                	addi	sp,sp,-464
    80005094:	e786                	sd	ra,456(sp)
    80005096:	e3a2                	sd	s0,448(sp)
    80005098:	ff26                	sd	s1,440(sp)
    8000509a:	fb4a                	sd	s2,432(sp)
    8000509c:	f74e                	sd	s3,424(sp)
    8000509e:	f352                	sd	s4,416(sp)
    800050a0:	ef56                	sd	s5,408(sp)
    800050a2:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800050a4:	e3840593          	addi	a1,s0,-456
    800050a8:	4505                	li	a0,1
    800050aa:	ffffd097          	auipc	ra,0xffffd
    800050ae:	1cc080e7          	jalr	460(ra) # 80002276 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800050b2:	08000613          	li	a2,128
    800050b6:	f4040593          	addi	a1,s0,-192
    800050ba:	4501                	li	a0,0
    800050bc:	ffffd097          	auipc	ra,0xffffd
    800050c0:	1da080e7          	jalr	474(ra) # 80002296 <argstr>
    800050c4:	87aa                	mv	a5,a0
    return -1;
    800050c6:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800050c8:	0c07c263          	bltz	a5,8000518c <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    800050cc:	10000613          	li	a2,256
    800050d0:	4581                	li	a1,0
    800050d2:	e4040513          	addi	a0,s0,-448
    800050d6:	ffffb097          	auipc	ra,0xffffb
    800050da:	1f0080e7          	jalr	496(ra) # 800002c6 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800050de:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800050e2:	89a6                	mv	s3,s1
    800050e4:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800050e6:	02000a13          	li	s4,32
    800050ea:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800050ee:	00391793          	slli	a5,s2,0x3
    800050f2:	e3040593          	addi	a1,s0,-464
    800050f6:	e3843503          	ld	a0,-456(s0)
    800050fa:	953e                	add	a0,a0,a5
    800050fc:	ffffd097          	auipc	ra,0xffffd
    80005100:	0bc080e7          	jalr	188(ra) # 800021b8 <fetchaddr>
    80005104:	02054a63          	bltz	a0,80005138 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005108:	e3043783          	ld	a5,-464(s0)
    8000510c:	c3b9                	beqz	a5,80005152 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000510e:	ffffb097          	auipc	ra,0xffffb
    80005112:	0b8080e7          	jalr	184(ra) # 800001c6 <kalloc>
    80005116:	85aa                	mv	a1,a0
    80005118:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000511c:	cd11                	beqz	a0,80005138 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000511e:	6605                	lui	a2,0x1
    80005120:	e3043503          	ld	a0,-464(s0)
    80005124:	ffffd097          	auipc	ra,0xffffd
    80005128:	0e6080e7          	jalr	230(ra) # 8000220a <fetchstr>
    8000512c:	00054663          	bltz	a0,80005138 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005130:	0905                	addi	s2,s2,1
    80005132:	09a1                	addi	s3,s3,8
    80005134:	fb491be3          	bne	s2,s4,800050ea <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005138:	10048913          	addi	s2,s1,256
    8000513c:	6088                	ld	a0,0(s1)
    8000513e:	c531                	beqz	a0,8000518a <sys_exec+0xf8>
    kfree(argv[i]);
    80005140:	ffffb097          	auipc	ra,0xffffb
    80005144:	edc080e7          	jalr	-292(ra) # 8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005148:	04a1                	addi	s1,s1,8
    8000514a:	ff2499e3          	bne	s1,s2,8000513c <sys_exec+0xaa>
  return -1;
    8000514e:	557d                	li	a0,-1
    80005150:	a835                	j	8000518c <sys_exec+0xfa>
      argv[i] = 0;
    80005152:	0a8e                	slli	s5,s5,0x3
    80005154:	fc040793          	addi	a5,s0,-64
    80005158:	9abe                	add	s5,s5,a5
    8000515a:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    8000515e:	e4040593          	addi	a1,s0,-448
    80005162:	f4040513          	addi	a0,s0,-192
    80005166:	fffff097          	auipc	ra,0xfffff
    8000516a:	172080e7          	jalr	370(ra) # 800042d8 <exec>
    8000516e:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005170:	10048993          	addi	s3,s1,256
    80005174:	6088                	ld	a0,0(s1)
    80005176:	c901                	beqz	a0,80005186 <sys_exec+0xf4>
    kfree(argv[i]);
    80005178:	ffffb097          	auipc	ra,0xffffb
    8000517c:	ea4080e7          	jalr	-348(ra) # 8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005180:	04a1                	addi	s1,s1,8
    80005182:	ff3499e3          	bne	s1,s3,80005174 <sys_exec+0xe2>
  return ret;
    80005186:	854a                	mv	a0,s2
    80005188:	a011                	j	8000518c <sys_exec+0xfa>
  return -1;
    8000518a:	557d                	li	a0,-1
}
    8000518c:	60be                	ld	ra,456(sp)
    8000518e:	641e                	ld	s0,448(sp)
    80005190:	74fa                	ld	s1,440(sp)
    80005192:	795a                	ld	s2,432(sp)
    80005194:	79ba                	ld	s3,424(sp)
    80005196:	7a1a                	ld	s4,416(sp)
    80005198:	6afa                	ld	s5,408(sp)
    8000519a:	6179                	addi	sp,sp,464
    8000519c:	8082                	ret

000000008000519e <sys_pipe>:

uint64
sys_pipe(void)
{
    8000519e:	7139                	addi	sp,sp,-64
    800051a0:	fc06                	sd	ra,56(sp)
    800051a2:	f822                	sd	s0,48(sp)
    800051a4:	f426                	sd	s1,40(sp)
    800051a6:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800051a8:	ffffc097          	auipc	ra,0xffffc
    800051ac:	f42080e7          	jalr	-190(ra) # 800010ea <myproc>
    800051b0:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800051b2:	fd840593          	addi	a1,s0,-40
    800051b6:	4501                	li	a0,0
    800051b8:	ffffd097          	auipc	ra,0xffffd
    800051bc:	0be080e7          	jalr	190(ra) # 80002276 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800051c0:	fc840593          	addi	a1,s0,-56
    800051c4:	fd040513          	addi	a0,s0,-48
    800051c8:	fffff097          	auipc	ra,0xfffff
    800051cc:	dc6080e7          	jalr	-570(ra) # 80003f8e <pipealloc>
    return -1;
    800051d0:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800051d2:	0c054463          	bltz	a0,8000529a <sys_pipe+0xfc>
  fd0 = -1;
    800051d6:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800051da:	fd043503          	ld	a0,-48(s0)
    800051de:	fffff097          	auipc	ra,0xfffff
    800051e2:	51a080e7          	jalr	1306(ra) # 800046f8 <fdalloc>
    800051e6:	fca42223          	sw	a0,-60(s0)
    800051ea:	08054b63          	bltz	a0,80005280 <sys_pipe+0xe2>
    800051ee:	fc843503          	ld	a0,-56(s0)
    800051f2:	fffff097          	auipc	ra,0xfffff
    800051f6:	506080e7          	jalr	1286(ra) # 800046f8 <fdalloc>
    800051fa:	fca42023          	sw	a0,-64(s0)
    800051fe:	06054863          	bltz	a0,8000526e <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005202:	4691                	li	a3,4
    80005204:	fc440613          	addi	a2,s0,-60
    80005208:	fd843583          	ld	a1,-40(s0)
    8000520c:	68a8                	ld	a0,80(s1)
    8000520e:	ffffc097          	auipc	ra,0xffffc
    80005212:	c6c080e7          	jalr	-916(ra) # 80000e7a <copyout>
    80005216:	02054063          	bltz	a0,80005236 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000521a:	4691                	li	a3,4
    8000521c:	fc040613          	addi	a2,s0,-64
    80005220:	fd843583          	ld	a1,-40(s0)
    80005224:	0591                	addi	a1,a1,4
    80005226:	68a8                	ld	a0,80(s1)
    80005228:	ffffc097          	auipc	ra,0xffffc
    8000522c:	c52080e7          	jalr	-942(ra) # 80000e7a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005230:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005232:	06055463          	bgez	a0,8000529a <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005236:	fc442783          	lw	a5,-60(s0)
    8000523a:	07e9                	addi	a5,a5,26
    8000523c:	078e                	slli	a5,a5,0x3
    8000523e:	97a6                	add	a5,a5,s1
    80005240:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005244:	fc042503          	lw	a0,-64(s0)
    80005248:	0569                	addi	a0,a0,26
    8000524a:	050e                	slli	a0,a0,0x3
    8000524c:	94aa                	add	s1,s1,a0
    8000524e:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005252:	fd043503          	ld	a0,-48(s0)
    80005256:	fffff097          	auipc	ra,0xfffff
    8000525a:	a08080e7          	jalr	-1528(ra) # 80003c5e <fileclose>
    fileclose(wf);
    8000525e:	fc843503          	ld	a0,-56(s0)
    80005262:	fffff097          	auipc	ra,0xfffff
    80005266:	9fc080e7          	jalr	-1540(ra) # 80003c5e <fileclose>
    return -1;
    8000526a:	57fd                	li	a5,-1
    8000526c:	a03d                	j	8000529a <sys_pipe+0xfc>
    if(fd0 >= 0)
    8000526e:	fc442783          	lw	a5,-60(s0)
    80005272:	0007c763          	bltz	a5,80005280 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005276:	07e9                	addi	a5,a5,26
    80005278:	078e                	slli	a5,a5,0x3
    8000527a:	94be                	add	s1,s1,a5
    8000527c:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005280:	fd043503          	ld	a0,-48(s0)
    80005284:	fffff097          	auipc	ra,0xfffff
    80005288:	9da080e7          	jalr	-1574(ra) # 80003c5e <fileclose>
    fileclose(wf);
    8000528c:	fc843503          	ld	a0,-56(s0)
    80005290:	fffff097          	auipc	ra,0xfffff
    80005294:	9ce080e7          	jalr	-1586(ra) # 80003c5e <fileclose>
    return -1;
    80005298:	57fd                	li	a5,-1
}
    8000529a:	853e                	mv	a0,a5
    8000529c:	70e2                	ld	ra,56(sp)
    8000529e:	7442                	ld	s0,48(sp)
    800052a0:	74a2                	ld	s1,40(sp)
    800052a2:	6121                	addi	sp,sp,64
    800052a4:	8082                	ret
	...

00000000800052b0 <kernelvec>:
    800052b0:	7111                	addi	sp,sp,-256
    800052b2:	e006                	sd	ra,0(sp)
    800052b4:	e40a                	sd	sp,8(sp)
    800052b6:	e80e                	sd	gp,16(sp)
    800052b8:	ec12                	sd	tp,24(sp)
    800052ba:	f016                	sd	t0,32(sp)
    800052bc:	f41a                	sd	t1,40(sp)
    800052be:	f81e                	sd	t2,48(sp)
    800052c0:	fc22                	sd	s0,56(sp)
    800052c2:	e0a6                	sd	s1,64(sp)
    800052c4:	e4aa                	sd	a0,72(sp)
    800052c6:	e8ae                	sd	a1,80(sp)
    800052c8:	ecb2                	sd	a2,88(sp)
    800052ca:	f0b6                	sd	a3,96(sp)
    800052cc:	f4ba                	sd	a4,104(sp)
    800052ce:	f8be                	sd	a5,112(sp)
    800052d0:	fcc2                	sd	a6,120(sp)
    800052d2:	e146                	sd	a7,128(sp)
    800052d4:	e54a                	sd	s2,136(sp)
    800052d6:	e94e                	sd	s3,144(sp)
    800052d8:	ed52                	sd	s4,152(sp)
    800052da:	f156                	sd	s5,160(sp)
    800052dc:	f55a                	sd	s6,168(sp)
    800052de:	f95e                	sd	s7,176(sp)
    800052e0:	fd62                	sd	s8,184(sp)
    800052e2:	e1e6                	sd	s9,192(sp)
    800052e4:	e5ea                	sd	s10,200(sp)
    800052e6:	e9ee                	sd	s11,208(sp)
    800052e8:	edf2                	sd	t3,216(sp)
    800052ea:	f1f6                	sd	t4,224(sp)
    800052ec:	f5fa                	sd	t5,232(sp)
    800052ee:	f9fe                	sd	t6,240(sp)
    800052f0:	d95fc0ef          	jal	ra,80002084 <kerneltrap>
    800052f4:	6082                	ld	ra,0(sp)
    800052f6:	6122                	ld	sp,8(sp)
    800052f8:	61c2                	ld	gp,16(sp)
    800052fa:	7282                	ld	t0,32(sp)
    800052fc:	7322                	ld	t1,40(sp)
    800052fe:	73c2                	ld	t2,48(sp)
    80005300:	7462                	ld	s0,56(sp)
    80005302:	6486                	ld	s1,64(sp)
    80005304:	6526                	ld	a0,72(sp)
    80005306:	65c6                	ld	a1,80(sp)
    80005308:	6666                	ld	a2,88(sp)
    8000530a:	7686                	ld	a3,96(sp)
    8000530c:	7726                	ld	a4,104(sp)
    8000530e:	77c6                	ld	a5,112(sp)
    80005310:	7866                	ld	a6,120(sp)
    80005312:	688a                	ld	a7,128(sp)
    80005314:	692a                	ld	s2,136(sp)
    80005316:	69ca                	ld	s3,144(sp)
    80005318:	6a6a                	ld	s4,152(sp)
    8000531a:	7a8a                	ld	s5,160(sp)
    8000531c:	7b2a                	ld	s6,168(sp)
    8000531e:	7bca                	ld	s7,176(sp)
    80005320:	7c6a                	ld	s8,184(sp)
    80005322:	6c8e                	ld	s9,192(sp)
    80005324:	6d2e                	ld	s10,200(sp)
    80005326:	6dce                	ld	s11,208(sp)
    80005328:	6e6e                	ld	t3,216(sp)
    8000532a:	7e8e                	ld	t4,224(sp)
    8000532c:	7f2e                	ld	t5,232(sp)
    8000532e:	7fce                	ld	t6,240(sp)
    80005330:	6111                	addi	sp,sp,256
    80005332:	10200073          	sret
    80005336:	00000013          	nop
    8000533a:	00000013          	nop
    8000533e:	0001                	nop

0000000080005340 <timervec>:
    80005340:	34051573          	csrrw	a0,mscratch,a0
    80005344:	e10c                	sd	a1,0(a0)
    80005346:	e510                	sd	a2,8(a0)
    80005348:	e914                	sd	a3,16(a0)
    8000534a:	6d0c                	ld	a1,24(a0)
    8000534c:	7110                	ld	a2,32(a0)
    8000534e:	6194                	ld	a3,0(a1)
    80005350:	96b2                	add	a3,a3,a2
    80005352:	e194                	sd	a3,0(a1)
    80005354:	4589                	li	a1,2
    80005356:	14459073          	csrw	sip,a1
    8000535a:	6914                	ld	a3,16(a0)
    8000535c:	6510                	ld	a2,8(a0)
    8000535e:	610c                	ld	a1,0(a0)
    80005360:	34051573          	csrrw	a0,mscratch,a0
    80005364:	30200073          	mret
	...

000000008000536a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000536a:	1141                	addi	sp,sp,-16
    8000536c:	e422                	sd	s0,8(sp)
    8000536e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005370:	0c0007b7          	lui	a5,0xc000
    80005374:	4705                	li	a4,1
    80005376:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005378:	c3d8                	sw	a4,4(a5)
}
    8000537a:	6422                	ld	s0,8(sp)
    8000537c:	0141                	addi	sp,sp,16
    8000537e:	8082                	ret

0000000080005380 <plicinithart>:

void
plicinithart(void)
{
    80005380:	1141                	addi	sp,sp,-16
    80005382:	e406                	sd	ra,8(sp)
    80005384:	e022                	sd	s0,0(sp)
    80005386:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005388:	ffffc097          	auipc	ra,0xffffc
    8000538c:	d36080e7          	jalr	-714(ra) # 800010be <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005390:	0085171b          	slliw	a4,a0,0x8
    80005394:	0c0027b7          	lui	a5,0xc002
    80005398:	97ba                	add	a5,a5,a4
    8000539a:	40200713          	li	a4,1026
    8000539e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800053a2:	00d5151b          	slliw	a0,a0,0xd
    800053a6:	0c2017b7          	lui	a5,0xc201
    800053aa:	953e                	add	a0,a0,a5
    800053ac:	00052023          	sw	zero,0(a0)
}
    800053b0:	60a2                	ld	ra,8(sp)
    800053b2:	6402                	ld	s0,0(sp)
    800053b4:	0141                	addi	sp,sp,16
    800053b6:	8082                	ret

00000000800053b8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800053b8:	1141                	addi	sp,sp,-16
    800053ba:	e406                	sd	ra,8(sp)
    800053bc:	e022                	sd	s0,0(sp)
    800053be:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800053c0:	ffffc097          	auipc	ra,0xffffc
    800053c4:	cfe080e7          	jalr	-770(ra) # 800010be <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800053c8:	00d5179b          	slliw	a5,a0,0xd
    800053cc:	0c201537          	lui	a0,0xc201
    800053d0:	953e                	add	a0,a0,a5
  return irq;
}
    800053d2:	4148                	lw	a0,4(a0)
    800053d4:	60a2                	ld	ra,8(sp)
    800053d6:	6402                	ld	s0,0(sp)
    800053d8:	0141                	addi	sp,sp,16
    800053da:	8082                	ret

00000000800053dc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800053dc:	1101                	addi	sp,sp,-32
    800053de:	ec06                	sd	ra,24(sp)
    800053e0:	e822                	sd	s0,16(sp)
    800053e2:	e426                	sd	s1,8(sp)
    800053e4:	1000                	addi	s0,sp,32
    800053e6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800053e8:	ffffc097          	auipc	ra,0xffffc
    800053ec:	cd6080e7          	jalr	-810(ra) # 800010be <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800053f0:	00d5151b          	slliw	a0,a0,0xd
    800053f4:	0c2017b7          	lui	a5,0xc201
    800053f8:	97aa                	add	a5,a5,a0
    800053fa:	c3c4                	sw	s1,4(a5)
}
    800053fc:	60e2                	ld	ra,24(sp)
    800053fe:	6442                	ld	s0,16(sp)
    80005400:	64a2                	ld	s1,8(sp)
    80005402:	6105                	addi	sp,sp,32
    80005404:	8082                	ret

0000000080005406 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005406:	1141                	addi	sp,sp,-16
    80005408:	e406                	sd	ra,8(sp)
    8000540a:	e022                	sd	s0,0(sp)
    8000540c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000540e:	479d                	li	a5,7
    80005410:	04a7cc63          	blt	a5,a0,80005468 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005414:	00114797          	auipc	a5,0x114
    80005418:	74c78793          	addi	a5,a5,1868 # 80119b60 <disk>
    8000541c:	97aa                	add	a5,a5,a0
    8000541e:	0187c783          	lbu	a5,24(a5)
    80005422:	ebb9                	bnez	a5,80005478 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005424:	00451613          	slli	a2,a0,0x4
    80005428:	00114797          	auipc	a5,0x114
    8000542c:	73878793          	addi	a5,a5,1848 # 80119b60 <disk>
    80005430:	6394                	ld	a3,0(a5)
    80005432:	96b2                	add	a3,a3,a2
    80005434:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005438:	6398                	ld	a4,0(a5)
    8000543a:	9732                	add	a4,a4,a2
    8000543c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005440:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005444:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005448:	953e                	add	a0,a0,a5
    8000544a:	4785                	li	a5,1
    8000544c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80005450:	00114517          	auipc	a0,0x114
    80005454:	72850513          	addi	a0,a0,1832 # 80119b78 <disk+0x18>
    80005458:	ffffc097          	auipc	ra,0xffffc
    8000545c:	3a2080e7          	jalr	930(ra) # 800017fa <wakeup>
}
    80005460:	60a2                	ld	ra,8(sp)
    80005462:	6402                	ld	s0,0(sp)
    80005464:	0141                	addi	sp,sp,16
    80005466:	8082                	ret
    panic("free_desc 1");
    80005468:	00003517          	auipc	a0,0x3
    8000546c:	2c050513          	addi	a0,a0,704 # 80008728 <syscalls+0x2f0>
    80005470:	00001097          	auipc	ra,0x1
    80005474:	a0e080e7          	jalr	-1522(ra) # 80005e7e <panic>
    panic("free_desc 2");
    80005478:	00003517          	auipc	a0,0x3
    8000547c:	2c050513          	addi	a0,a0,704 # 80008738 <syscalls+0x300>
    80005480:	00001097          	auipc	ra,0x1
    80005484:	9fe080e7          	jalr	-1538(ra) # 80005e7e <panic>

0000000080005488 <virtio_disk_init>:
{
    80005488:	1101                	addi	sp,sp,-32
    8000548a:	ec06                	sd	ra,24(sp)
    8000548c:	e822                	sd	s0,16(sp)
    8000548e:	e426                	sd	s1,8(sp)
    80005490:	e04a                	sd	s2,0(sp)
    80005492:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005494:	00003597          	auipc	a1,0x3
    80005498:	2b458593          	addi	a1,a1,692 # 80008748 <syscalls+0x310>
    8000549c:	00114517          	auipc	a0,0x114
    800054a0:	7ec50513          	addi	a0,a0,2028 # 80119c88 <disk+0x128>
    800054a4:	00001097          	auipc	ra,0x1
    800054a8:	e86080e7          	jalr	-378(ra) # 8000632a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800054ac:	100017b7          	lui	a5,0x10001
    800054b0:	4398                	lw	a4,0(a5)
    800054b2:	2701                	sext.w	a4,a4
    800054b4:	747277b7          	lui	a5,0x74727
    800054b8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800054bc:	14f71c63          	bne	a4,a5,80005614 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800054c0:	100017b7          	lui	a5,0x10001
    800054c4:	43dc                	lw	a5,4(a5)
    800054c6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800054c8:	4709                	li	a4,2
    800054ca:	14e79563          	bne	a5,a4,80005614 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800054ce:	100017b7          	lui	a5,0x10001
    800054d2:	479c                	lw	a5,8(a5)
    800054d4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800054d6:	12e79f63          	bne	a5,a4,80005614 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800054da:	100017b7          	lui	a5,0x10001
    800054de:	47d8                	lw	a4,12(a5)
    800054e0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800054e2:	554d47b7          	lui	a5,0x554d4
    800054e6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800054ea:	12f71563          	bne	a4,a5,80005614 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    800054ee:	100017b7          	lui	a5,0x10001
    800054f2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800054f6:	4705                	li	a4,1
    800054f8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800054fa:	470d                	li	a4,3
    800054fc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800054fe:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005500:	c7ffe737          	lui	a4,0xc7ffe
    80005504:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47edc87f>
    80005508:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000550a:	2701                	sext.w	a4,a4
    8000550c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000550e:	472d                	li	a4,11
    80005510:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005512:	5bbc                	lw	a5,112(a5)
    80005514:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005518:	8ba1                	andi	a5,a5,8
    8000551a:	10078563          	beqz	a5,80005624 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000551e:	100017b7          	lui	a5,0x10001
    80005522:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005526:	43fc                	lw	a5,68(a5)
    80005528:	2781                	sext.w	a5,a5
    8000552a:	10079563          	bnez	a5,80005634 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000552e:	100017b7          	lui	a5,0x10001
    80005532:	5bdc                	lw	a5,52(a5)
    80005534:	2781                	sext.w	a5,a5
  if(max == 0)
    80005536:	10078763          	beqz	a5,80005644 <virtio_disk_init+0x1bc>
  if(max < NUM)
    8000553a:	471d                	li	a4,7
    8000553c:	10f77c63          	bgeu	a4,a5,80005654 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    80005540:	ffffb097          	auipc	ra,0xffffb
    80005544:	c86080e7          	jalr	-890(ra) # 800001c6 <kalloc>
    80005548:	00114497          	auipc	s1,0x114
    8000554c:	61848493          	addi	s1,s1,1560 # 80119b60 <disk>
    80005550:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005552:	ffffb097          	auipc	ra,0xffffb
    80005556:	c74080e7          	jalr	-908(ra) # 800001c6 <kalloc>
    8000555a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000555c:	ffffb097          	auipc	ra,0xffffb
    80005560:	c6a080e7          	jalr	-918(ra) # 800001c6 <kalloc>
    80005564:	87aa                	mv	a5,a0
    80005566:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005568:	6088                	ld	a0,0(s1)
    8000556a:	cd6d                	beqz	a0,80005664 <virtio_disk_init+0x1dc>
    8000556c:	00114717          	auipc	a4,0x114
    80005570:	5fc73703          	ld	a4,1532(a4) # 80119b68 <disk+0x8>
    80005574:	cb65                	beqz	a4,80005664 <virtio_disk_init+0x1dc>
    80005576:	c7fd                	beqz	a5,80005664 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    80005578:	6605                	lui	a2,0x1
    8000557a:	4581                	li	a1,0
    8000557c:	ffffb097          	auipc	ra,0xffffb
    80005580:	d4a080e7          	jalr	-694(ra) # 800002c6 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005584:	00114497          	auipc	s1,0x114
    80005588:	5dc48493          	addi	s1,s1,1500 # 80119b60 <disk>
    8000558c:	6605                	lui	a2,0x1
    8000558e:	4581                	li	a1,0
    80005590:	6488                	ld	a0,8(s1)
    80005592:	ffffb097          	auipc	ra,0xffffb
    80005596:	d34080e7          	jalr	-716(ra) # 800002c6 <memset>
  memset(disk.used, 0, PGSIZE);
    8000559a:	6605                	lui	a2,0x1
    8000559c:	4581                	li	a1,0
    8000559e:	6888                	ld	a0,16(s1)
    800055a0:	ffffb097          	auipc	ra,0xffffb
    800055a4:	d26080e7          	jalr	-730(ra) # 800002c6 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800055a8:	100017b7          	lui	a5,0x10001
    800055ac:	4721                	li	a4,8
    800055ae:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800055b0:	4098                	lw	a4,0(s1)
    800055b2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800055b6:	40d8                	lw	a4,4(s1)
    800055b8:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800055bc:	6498                	ld	a4,8(s1)
    800055be:	0007069b          	sext.w	a3,a4
    800055c2:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800055c6:	9701                	srai	a4,a4,0x20
    800055c8:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800055cc:	6898                	ld	a4,16(s1)
    800055ce:	0007069b          	sext.w	a3,a4
    800055d2:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800055d6:	9701                	srai	a4,a4,0x20
    800055d8:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800055dc:	4705                	li	a4,1
    800055de:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800055e0:	00e48c23          	sb	a4,24(s1)
    800055e4:	00e48ca3          	sb	a4,25(s1)
    800055e8:	00e48d23          	sb	a4,26(s1)
    800055ec:	00e48da3          	sb	a4,27(s1)
    800055f0:	00e48e23          	sb	a4,28(s1)
    800055f4:	00e48ea3          	sb	a4,29(s1)
    800055f8:	00e48f23          	sb	a4,30(s1)
    800055fc:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005600:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005604:	0727a823          	sw	s2,112(a5)
}
    80005608:	60e2                	ld	ra,24(sp)
    8000560a:	6442                	ld	s0,16(sp)
    8000560c:	64a2                	ld	s1,8(sp)
    8000560e:	6902                	ld	s2,0(sp)
    80005610:	6105                	addi	sp,sp,32
    80005612:	8082                	ret
    panic("could not find virtio disk");
    80005614:	00003517          	auipc	a0,0x3
    80005618:	14450513          	addi	a0,a0,324 # 80008758 <syscalls+0x320>
    8000561c:	00001097          	auipc	ra,0x1
    80005620:	862080e7          	jalr	-1950(ra) # 80005e7e <panic>
    panic("virtio disk FEATURES_OK unset");
    80005624:	00003517          	auipc	a0,0x3
    80005628:	15450513          	addi	a0,a0,340 # 80008778 <syscalls+0x340>
    8000562c:	00001097          	auipc	ra,0x1
    80005630:	852080e7          	jalr	-1966(ra) # 80005e7e <panic>
    panic("virtio disk should not be ready");
    80005634:	00003517          	auipc	a0,0x3
    80005638:	16450513          	addi	a0,a0,356 # 80008798 <syscalls+0x360>
    8000563c:	00001097          	auipc	ra,0x1
    80005640:	842080e7          	jalr	-1982(ra) # 80005e7e <panic>
    panic("virtio disk has no queue 0");
    80005644:	00003517          	auipc	a0,0x3
    80005648:	17450513          	addi	a0,a0,372 # 800087b8 <syscalls+0x380>
    8000564c:	00001097          	auipc	ra,0x1
    80005650:	832080e7          	jalr	-1998(ra) # 80005e7e <panic>
    panic("virtio disk max queue too short");
    80005654:	00003517          	auipc	a0,0x3
    80005658:	18450513          	addi	a0,a0,388 # 800087d8 <syscalls+0x3a0>
    8000565c:	00001097          	auipc	ra,0x1
    80005660:	822080e7          	jalr	-2014(ra) # 80005e7e <panic>
    panic("virtio disk kalloc");
    80005664:	00003517          	auipc	a0,0x3
    80005668:	19450513          	addi	a0,a0,404 # 800087f8 <syscalls+0x3c0>
    8000566c:	00001097          	auipc	ra,0x1
    80005670:	812080e7          	jalr	-2030(ra) # 80005e7e <panic>

0000000080005674 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005674:	7119                	addi	sp,sp,-128
    80005676:	fc86                	sd	ra,120(sp)
    80005678:	f8a2                	sd	s0,112(sp)
    8000567a:	f4a6                	sd	s1,104(sp)
    8000567c:	f0ca                	sd	s2,96(sp)
    8000567e:	ecce                	sd	s3,88(sp)
    80005680:	e8d2                	sd	s4,80(sp)
    80005682:	e4d6                	sd	s5,72(sp)
    80005684:	e0da                	sd	s6,64(sp)
    80005686:	fc5e                	sd	s7,56(sp)
    80005688:	f862                	sd	s8,48(sp)
    8000568a:	f466                	sd	s9,40(sp)
    8000568c:	f06a                	sd	s10,32(sp)
    8000568e:	ec6e                	sd	s11,24(sp)
    80005690:	0100                	addi	s0,sp,128
    80005692:	8aaa                	mv	s5,a0
    80005694:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005696:	00c52d03          	lw	s10,12(a0)
    8000569a:	001d1d1b          	slliw	s10,s10,0x1
    8000569e:	1d02                	slli	s10,s10,0x20
    800056a0:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800056a4:	00114517          	auipc	a0,0x114
    800056a8:	5e450513          	addi	a0,a0,1508 # 80119c88 <disk+0x128>
    800056ac:	00001097          	auipc	ra,0x1
    800056b0:	d0e080e7          	jalr	-754(ra) # 800063ba <acquire>
  for(int i = 0; i < 3; i++){
    800056b4:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800056b6:	44a1                	li	s1,8
      disk.free[i] = 0;
    800056b8:	00114b97          	auipc	s7,0x114
    800056bc:	4a8b8b93          	addi	s7,s7,1192 # 80119b60 <disk>
  for(int i = 0; i < 3; i++){
    800056c0:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800056c2:	00114c97          	auipc	s9,0x114
    800056c6:	5c6c8c93          	addi	s9,s9,1478 # 80119c88 <disk+0x128>
    800056ca:	a08d                	j	8000572c <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    800056cc:	00fb8733          	add	a4,s7,a5
    800056d0:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800056d4:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800056d6:	0207c563          	bltz	a5,80005700 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800056da:	2905                	addiw	s2,s2,1
    800056dc:	0611                	addi	a2,a2,4
    800056de:	05690c63          	beq	s2,s6,80005736 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    800056e2:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800056e4:	00114717          	auipc	a4,0x114
    800056e8:	47c70713          	addi	a4,a4,1148 # 80119b60 <disk>
    800056ec:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800056ee:	01874683          	lbu	a3,24(a4)
    800056f2:	fee9                	bnez	a3,800056cc <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800056f4:	2785                	addiw	a5,a5,1
    800056f6:	0705                	addi	a4,a4,1
    800056f8:	fe979be3          	bne	a5,s1,800056ee <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800056fc:	57fd                	li	a5,-1
    800056fe:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005700:	01205d63          	blez	s2,8000571a <virtio_disk_rw+0xa6>
    80005704:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80005706:	000a2503          	lw	a0,0(s4)
    8000570a:	00000097          	auipc	ra,0x0
    8000570e:	cfc080e7          	jalr	-772(ra) # 80005406 <free_desc>
      for(int j = 0; j < i; j++)
    80005712:	2d85                	addiw	s11,s11,1
    80005714:	0a11                	addi	s4,s4,4
    80005716:	ffb918e3          	bne	s2,s11,80005706 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000571a:	85e6                	mv	a1,s9
    8000571c:	00114517          	auipc	a0,0x114
    80005720:	45c50513          	addi	a0,a0,1116 # 80119b78 <disk+0x18>
    80005724:	ffffc097          	auipc	ra,0xffffc
    80005728:	072080e7          	jalr	114(ra) # 80001796 <sleep>
  for(int i = 0; i < 3; i++){
    8000572c:	f8040a13          	addi	s4,s0,-128
{
    80005730:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80005732:	894e                	mv	s2,s3
    80005734:	b77d                	j	800056e2 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005736:	f8042583          	lw	a1,-128(s0)
    8000573a:	00a58793          	addi	a5,a1,10
    8000573e:	0792                	slli	a5,a5,0x4

  if(write)
    80005740:	00114617          	auipc	a2,0x114
    80005744:	42060613          	addi	a2,a2,1056 # 80119b60 <disk>
    80005748:	00f60733          	add	a4,a2,a5
    8000574c:	018036b3          	snez	a3,s8
    80005750:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005752:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005756:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000575a:	f6078693          	addi	a3,a5,-160
    8000575e:	6218                	ld	a4,0(a2)
    80005760:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005762:	00878513          	addi	a0,a5,8
    80005766:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005768:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000576a:	6208                	ld	a0,0(a2)
    8000576c:	96aa                	add	a3,a3,a0
    8000576e:	4741                	li	a4,16
    80005770:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005772:	4705                	li	a4,1
    80005774:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80005778:	f8442703          	lw	a4,-124(s0)
    8000577c:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005780:	0712                	slli	a4,a4,0x4
    80005782:	953a                	add	a0,a0,a4
    80005784:	058a8693          	addi	a3,s5,88
    80005788:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000578a:	6208                	ld	a0,0(a2)
    8000578c:	972a                	add	a4,a4,a0
    8000578e:	40000693          	li	a3,1024
    80005792:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80005794:	001c3c13          	seqz	s8,s8
    80005798:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000579a:	001c6c13          	ori	s8,s8,1
    8000579e:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800057a2:	f8842603          	lw	a2,-120(s0)
    800057a6:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800057aa:	00114697          	auipc	a3,0x114
    800057ae:	3b668693          	addi	a3,a3,950 # 80119b60 <disk>
    800057b2:	00258713          	addi	a4,a1,2
    800057b6:	0712                	slli	a4,a4,0x4
    800057b8:	9736                	add	a4,a4,a3
    800057ba:	587d                	li	a6,-1
    800057bc:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800057c0:	0612                	slli	a2,a2,0x4
    800057c2:	9532                	add	a0,a0,a2
    800057c4:	f9078793          	addi	a5,a5,-112
    800057c8:	97b6                	add	a5,a5,a3
    800057ca:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    800057cc:	629c                	ld	a5,0(a3)
    800057ce:	97b2                	add	a5,a5,a2
    800057d0:	4605                	li	a2,1
    800057d2:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800057d4:	4509                	li	a0,2
    800057d6:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    800057da:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800057de:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800057e2:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800057e6:	6698                	ld	a4,8(a3)
    800057e8:	00275783          	lhu	a5,2(a4)
    800057ec:	8b9d                	andi	a5,a5,7
    800057ee:	0786                	slli	a5,a5,0x1
    800057f0:	97ba                	add	a5,a5,a4
    800057f2:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    800057f6:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800057fa:	6698                	ld	a4,8(a3)
    800057fc:	00275783          	lhu	a5,2(a4)
    80005800:	2785                	addiw	a5,a5,1
    80005802:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005806:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000580a:	100017b7          	lui	a5,0x10001
    8000580e:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005812:	004aa783          	lw	a5,4(s5)
    80005816:	02c79163          	bne	a5,a2,80005838 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    8000581a:	00114917          	auipc	s2,0x114
    8000581e:	46e90913          	addi	s2,s2,1134 # 80119c88 <disk+0x128>
  while(b->disk == 1) {
    80005822:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80005824:	85ca                	mv	a1,s2
    80005826:	8556                	mv	a0,s5
    80005828:	ffffc097          	auipc	ra,0xffffc
    8000582c:	f6e080e7          	jalr	-146(ra) # 80001796 <sleep>
  while(b->disk == 1) {
    80005830:	004aa783          	lw	a5,4(s5)
    80005834:	fe9788e3          	beq	a5,s1,80005824 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80005838:	f8042903          	lw	s2,-128(s0)
    8000583c:	00290793          	addi	a5,s2,2
    80005840:	00479713          	slli	a4,a5,0x4
    80005844:	00114797          	auipc	a5,0x114
    80005848:	31c78793          	addi	a5,a5,796 # 80119b60 <disk>
    8000584c:	97ba                	add	a5,a5,a4
    8000584e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005852:	00114997          	auipc	s3,0x114
    80005856:	30e98993          	addi	s3,s3,782 # 80119b60 <disk>
    8000585a:	00491713          	slli	a4,s2,0x4
    8000585e:	0009b783          	ld	a5,0(s3)
    80005862:	97ba                	add	a5,a5,a4
    80005864:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005868:	854a                	mv	a0,s2
    8000586a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000586e:	00000097          	auipc	ra,0x0
    80005872:	b98080e7          	jalr	-1128(ra) # 80005406 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005876:	8885                	andi	s1,s1,1
    80005878:	f0ed                	bnez	s1,8000585a <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000587a:	00114517          	auipc	a0,0x114
    8000587e:	40e50513          	addi	a0,a0,1038 # 80119c88 <disk+0x128>
    80005882:	00001097          	auipc	ra,0x1
    80005886:	bec080e7          	jalr	-1044(ra) # 8000646e <release>
}
    8000588a:	70e6                	ld	ra,120(sp)
    8000588c:	7446                	ld	s0,112(sp)
    8000588e:	74a6                	ld	s1,104(sp)
    80005890:	7906                	ld	s2,96(sp)
    80005892:	69e6                	ld	s3,88(sp)
    80005894:	6a46                	ld	s4,80(sp)
    80005896:	6aa6                	ld	s5,72(sp)
    80005898:	6b06                	ld	s6,64(sp)
    8000589a:	7be2                	ld	s7,56(sp)
    8000589c:	7c42                	ld	s8,48(sp)
    8000589e:	7ca2                	ld	s9,40(sp)
    800058a0:	7d02                	ld	s10,32(sp)
    800058a2:	6de2                	ld	s11,24(sp)
    800058a4:	6109                	addi	sp,sp,128
    800058a6:	8082                	ret

00000000800058a8 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800058a8:	1101                	addi	sp,sp,-32
    800058aa:	ec06                	sd	ra,24(sp)
    800058ac:	e822                	sd	s0,16(sp)
    800058ae:	e426                	sd	s1,8(sp)
    800058b0:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800058b2:	00114497          	auipc	s1,0x114
    800058b6:	2ae48493          	addi	s1,s1,686 # 80119b60 <disk>
    800058ba:	00114517          	auipc	a0,0x114
    800058be:	3ce50513          	addi	a0,a0,974 # 80119c88 <disk+0x128>
    800058c2:	00001097          	auipc	ra,0x1
    800058c6:	af8080e7          	jalr	-1288(ra) # 800063ba <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800058ca:	10001737          	lui	a4,0x10001
    800058ce:	533c                	lw	a5,96(a4)
    800058d0:	8b8d                	andi	a5,a5,3
    800058d2:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800058d4:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800058d8:	689c                	ld	a5,16(s1)
    800058da:	0204d703          	lhu	a4,32(s1)
    800058de:	0027d783          	lhu	a5,2(a5)
    800058e2:	04f70863          	beq	a4,a5,80005932 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800058e6:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800058ea:	6898                	ld	a4,16(s1)
    800058ec:	0204d783          	lhu	a5,32(s1)
    800058f0:	8b9d                	andi	a5,a5,7
    800058f2:	078e                	slli	a5,a5,0x3
    800058f4:	97ba                	add	a5,a5,a4
    800058f6:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800058f8:	00278713          	addi	a4,a5,2
    800058fc:	0712                	slli	a4,a4,0x4
    800058fe:	9726                	add	a4,a4,s1
    80005900:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80005904:	e721                	bnez	a4,8000594c <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005906:	0789                	addi	a5,a5,2
    80005908:	0792                	slli	a5,a5,0x4
    8000590a:	97a6                	add	a5,a5,s1
    8000590c:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000590e:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005912:	ffffc097          	auipc	ra,0xffffc
    80005916:	ee8080e7          	jalr	-280(ra) # 800017fa <wakeup>

    disk.used_idx += 1;
    8000591a:	0204d783          	lhu	a5,32(s1)
    8000591e:	2785                	addiw	a5,a5,1
    80005920:	17c2                	slli	a5,a5,0x30
    80005922:	93c1                	srli	a5,a5,0x30
    80005924:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005928:	6898                	ld	a4,16(s1)
    8000592a:	00275703          	lhu	a4,2(a4)
    8000592e:	faf71ce3          	bne	a4,a5,800058e6 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005932:	00114517          	auipc	a0,0x114
    80005936:	35650513          	addi	a0,a0,854 # 80119c88 <disk+0x128>
    8000593a:	00001097          	auipc	ra,0x1
    8000593e:	b34080e7          	jalr	-1228(ra) # 8000646e <release>
}
    80005942:	60e2                	ld	ra,24(sp)
    80005944:	6442                	ld	s0,16(sp)
    80005946:	64a2                	ld	s1,8(sp)
    80005948:	6105                	addi	sp,sp,32
    8000594a:	8082                	ret
      panic("virtio_disk_intr status");
    8000594c:	00003517          	auipc	a0,0x3
    80005950:	ec450513          	addi	a0,a0,-316 # 80008810 <syscalls+0x3d8>
    80005954:	00000097          	auipc	ra,0x0
    80005958:	52a080e7          	jalr	1322(ra) # 80005e7e <panic>

000000008000595c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000595c:	1141                	addi	sp,sp,-16
    8000595e:	e422                	sd	s0,8(sp)
    80005960:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80005962:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80005966:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000596a:	0037979b          	slliw	a5,a5,0x3
    8000596e:	02004737          	lui	a4,0x2004
    80005972:	97ba                	add	a5,a5,a4
    80005974:	0200c737          	lui	a4,0x200c
    80005978:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000597c:	000f4637          	lui	a2,0xf4
    80005980:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80005984:	95b2                	add	a1,a1,a2
    80005986:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80005988:	00269713          	slli	a4,a3,0x2
    8000598c:	9736                	add	a4,a4,a3
    8000598e:	00371693          	slli	a3,a4,0x3
    80005992:	00114717          	auipc	a4,0x114
    80005996:	30e70713          	addi	a4,a4,782 # 80119ca0 <timer_scratch>
    8000599a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000599c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000599e:	f310                	sd	a2,32(a4)
  asm volatile("csrw mscratch, %0" : : "r" (x));
    800059a0:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    800059a4:	00000797          	auipc	a5,0x0
    800059a8:	99c78793          	addi	a5,a5,-1636 # 80005340 <timervec>
    800059ac:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    800059b0:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    800059b4:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800059b8:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    800059bc:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    800059c0:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    800059c4:	30479073          	csrw	mie,a5
}
    800059c8:	6422                	ld	s0,8(sp)
    800059ca:	0141                	addi	sp,sp,16
    800059cc:	8082                	ret

00000000800059ce <start>:
{
    800059ce:	1141                	addi	sp,sp,-16
    800059d0:	e406                	sd	ra,8(sp)
    800059d2:	e022                	sd	s0,0(sp)
    800059d4:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    800059d6:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    800059da:	7779                	lui	a4,0xffffe
    800059dc:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fedc91f>
    800059e0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800059e2:	6705                	lui	a4,0x1
    800059e4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800059e8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800059ea:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800059ee:	ffffb797          	auipc	a5,0xffffb
    800059f2:	a7e78793          	addi	a5,a5,-1410 # 8000046c <main>
    800059f6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800059fa:	4781                	li	a5,0
    800059fc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80005a00:	67c1                	lui	a5,0x10
    80005a02:	17fd                	addi	a5,a5,-1
    80005a04:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    80005a08:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    80005a0c:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80005a10:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80005a14:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    80005a18:	57fd                	li	a5,-1
    80005a1a:	83a9                	srli	a5,a5,0xa
    80005a1c:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    80005a20:	47bd                	li	a5,15
    80005a22:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    80005a26:	00000097          	auipc	ra,0x0
    80005a2a:	f36080e7          	jalr	-202(ra) # 8000595c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80005a2e:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    80005a32:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    80005a34:	823e                	mv	tp,a5
  asm volatile("mret");
    80005a36:	30200073          	mret
}
    80005a3a:	60a2                	ld	ra,8(sp)
    80005a3c:	6402                	ld	s0,0(sp)
    80005a3e:	0141                	addi	sp,sp,16
    80005a40:	8082                	ret

0000000080005a42 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80005a42:	715d                	addi	sp,sp,-80
    80005a44:	e486                	sd	ra,72(sp)
    80005a46:	e0a2                	sd	s0,64(sp)
    80005a48:	fc26                	sd	s1,56(sp)
    80005a4a:	f84a                	sd	s2,48(sp)
    80005a4c:	f44e                	sd	s3,40(sp)
    80005a4e:	f052                	sd	s4,32(sp)
    80005a50:	ec56                	sd	s5,24(sp)
    80005a52:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80005a54:	04c05663          	blez	a2,80005aa0 <consolewrite+0x5e>
    80005a58:	8a2a                	mv	s4,a0
    80005a5a:	84ae                	mv	s1,a1
    80005a5c:	89b2                	mv	s3,a2
    80005a5e:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80005a60:	5afd                	li	s5,-1
    80005a62:	4685                	li	a3,1
    80005a64:	8626                	mv	a2,s1
    80005a66:	85d2                	mv	a1,s4
    80005a68:	fbf40513          	addi	a0,s0,-65
    80005a6c:	ffffc097          	auipc	ra,0xffffc
    80005a70:	188080e7          	jalr	392(ra) # 80001bf4 <either_copyin>
    80005a74:	01550c63          	beq	a0,s5,80005a8c <consolewrite+0x4a>
      break;
    uartputc(c);
    80005a78:	fbf44503          	lbu	a0,-65(s0)
    80005a7c:	00000097          	auipc	ra,0x0
    80005a80:	780080e7          	jalr	1920(ra) # 800061fc <uartputc>
  for(i = 0; i < n; i++){
    80005a84:	2905                	addiw	s2,s2,1
    80005a86:	0485                	addi	s1,s1,1
    80005a88:	fd299de3          	bne	s3,s2,80005a62 <consolewrite+0x20>
  }

  return i;
}
    80005a8c:	854a                	mv	a0,s2
    80005a8e:	60a6                	ld	ra,72(sp)
    80005a90:	6406                	ld	s0,64(sp)
    80005a92:	74e2                	ld	s1,56(sp)
    80005a94:	7942                	ld	s2,48(sp)
    80005a96:	79a2                	ld	s3,40(sp)
    80005a98:	7a02                	ld	s4,32(sp)
    80005a9a:	6ae2                	ld	s5,24(sp)
    80005a9c:	6161                	addi	sp,sp,80
    80005a9e:	8082                	ret
  for(i = 0; i < n; i++){
    80005aa0:	4901                	li	s2,0
    80005aa2:	b7ed                	j	80005a8c <consolewrite+0x4a>

0000000080005aa4 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80005aa4:	7159                	addi	sp,sp,-112
    80005aa6:	f486                	sd	ra,104(sp)
    80005aa8:	f0a2                	sd	s0,96(sp)
    80005aaa:	eca6                	sd	s1,88(sp)
    80005aac:	e8ca                	sd	s2,80(sp)
    80005aae:	e4ce                	sd	s3,72(sp)
    80005ab0:	e0d2                	sd	s4,64(sp)
    80005ab2:	fc56                	sd	s5,56(sp)
    80005ab4:	f85a                	sd	s6,48(sp)
    80005ab6:	f45e                	sd	s7,40(sp)
    80005ab8:	f062                	sd	s8,32(sp)
    80005aba:	ec66                	sd	s9,24(sp)
    80005abc:	e86a                	sd	s10,16(sp)
    80005abe:	1880                	addi	s0,sp,112
    80005ac0:	8aaa                	mv	s5,a0
    80005ac2:	8a2e                	mv	s4,a1
    80005ac4:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80005ac6:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80005aca:	0011c517          	auipc	a0,0x11c
    80005ace:	31650513          	addi	a0,a0,790 # 80121de0 <cons>
    80005ad2:	00001097          	auipc	ra,0x1
    80005ad6:	8e8080e7          	jalr	-1816(ra) # 800063ba <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80005ada:	0011c497          	auipc	s1,0x11c
    80005ade:	30648493          	addi	s1,s1,774 # 80121de0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80005ae2:	0011c917          	auipc	s2,0x11c
    80005ae6:	39690913          	addi	s2,s2,918 # 80121e78 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    80005aea:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80005aec:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    80005aee:	4ca9                	li	s9,10
  while(n > 0){
    80005af0:	07305b63          	blez	s3,80005b66 <consoleread+0xc2>
    while(cons.r == cons.w){
    80005af4:	0984a783          	lw	a5,152(s1)
    80005af8:	09c4a703          	lw	a4,156(s1)
    80005afc:	02f71763          	bne	a4,a5,80005b2a <consoleread+0x86>
      if(killed(myproc())){
    80005b00:	ffffb097          	auipc	ra,0xffffb
    80005b04:	5ea080e7          	jalr	1514(ra) # 800010ea <myproc>
    80005b08:	ffffc097          	auipc	ra,0xffffc
    80005b0c:	f36080e7          	jalr	-202(ra) # 80001a3e <killed>
    80005b10:	e535                	bnez	a0,80005b7c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    80005b12:	85a6                	mv	a1,s1
    80005b14:	854a                	mv	a0,s2
    80005b16:	ffffc097          	auipc	ra,0xffffc
    80005b1a:	c80080e7          	jalr	-896(ra) # 80001796 <sleep>
    while(cons.r == cons.w){
    80005b1e:	0984a783          	lw	a5,152(s1)
    80005b22:	09c4a703          	lw	a4,156(s1)
    80005b26:	fcf70de3          	beq	a4,a5,80005b00 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    80005b2a:	0017871b          	addiw	a4,a5,1
    80005b2e:	08e4ac23          	sw	a4,152(s1)
    80005b32:	07f7f713          	andi	a4,a5,127
    80005b36:	9726                	add	a4,a4,s1
    80005b38:	01874703          	lbu	a4,24(a4)
    80005b3c:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80005b40:	077d0563          	beq	s10,s7,80005baa <consoleread+0x106>
    cbuf = c;
    80005b44:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80005b48:	4685                	li	a3,1
    80005b4a:	f9f40613          	addi	a2,s0,-97
    80005b4e:	85d2                	mv	a1,s4
    80005b50:	8556                	mv	a0,s5
    80005b52:	ffffc097          	auipc	ra,0xffffc
    80005b56:	04c080e7          	jalr	76(ra) # 80001b9e <either_copyout>
    80005b5a:	01850663          	beq	a0,s8,80005b66 <consoleread+0xc2>
    dst++;
    80005b5e:	0a05                	addi	s4,s4,1
    --n;
    80005b60:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80005b62:	f99d17e3          	bne	s10,s9,80005af0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80005b66:	0011c517          	auipc	a0,0x11c
    80005b6a:	27a50513          	addi	a0,a0,634 # 80121de0 <cons>
    80005b6e:	00001097          	auipc	ra,0x1
    80005b72:	900080e7          	jalr	-1792(ra) # 8000646e <release>

  return target - n;
    80005b76:	413b053b          	subw	a0,s6,s3
    80005b7a:	a811                	j	80005b8e <consoleread+0xea>
        release(&cons.lock);
    80005b7c:	0011c517          	auipc	a0,0x11c
    80005b80:	26450513          	addi	a0,a0,612 # 80121de0 <cons>
    80005b84:	00001097          	auipc	ra,0x1
    80005b88:	8ea080e7          	jalr	-1814(ra) # 8000646e <release>
        return -1;
    80005b8c:	557d                	li	a0,-1
}
    80005b8e:	70a6                	ld	ra,104(sp)
    80005b90:	7406                	ld	s0,96(sp)
    80005b92:	64e6                	ld	s1,88(sp)
    80005b94:	6946                	ld	s2,80(sp)
    80005b96:	69a6                	ld	s3,72(sp)
    80005b98:	6a06                	ld	s4,64(sp)
    80005b9a:	7ae2                	ld	s5,56(sp)
    80005b9c:	7b42                	ld	s6,48(sp)
    80005b9e:	7ba2                	ld	s7,40(sp)
    80005ba0:	7c02                	ld	s8,32(sp)
    80005ba2:	6ce2                	ld	s9,24(sp)
    80005ba4:	6d42                	ld	s10,16(sp)
    80005ba6:	6165                	addi	sp,sp,112
    80005ba8:	8082                	ret
      if(n < target){
    80005baa:	0009871b          	sext.w	a4,s3
    80005bae:	fb677ce3          	bgeu	a4,s6,80005b66 <consoleread+0xc2>
        cons.r--;
    80005bb2:	0011c717          	auipc	a4,0x11c
    80005bb6:	2cf72323          	sw	a5,710(a4) # 80121e78 <cons+0x98>
    80005bba:	b775                	j	80005b66 <consoleread+0xc2>

0000000080005bbc <consputc>:
{
    80005bbc:	1141                	addi	sp,sp,-16
    80005bbe:	e406                	sd	ra,8(sp)
    80005bc0:	e022                	sd	s0,0(sp)
    80005bc2:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80005bc4:	10000793          	li	a5,256
    80005bc8:	00f50a63          	beq	a0,a5,80005bdc <consputc+0x20>
    uartputc_sync(c);
    80005bcc:	00000097          	auipc	ra,0x0
    80005bd0:	55e080e7          	jalr	1374(ra) # 8000612a <uartputc_sync>
}
    80005bd4:	60a2                	ld	ra,8(sp)
    80005bd6:	6402                	ld	s0,0(sp)
    80005bd8:	0141                	addi	sp,sp,16
    80005bda:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80005bdc:	4521                	li	a0,8
    80005bde:	00000097          	auipc	ra,0x0
    80005be2:	54c080e7          	jalr	1356(ra) # 8000612a <uartputc_sync>
    80005be6:	02000513          	li	a0,32
    80005bea:	00000097          	auipc	ra,0x0
    80005bee:	540080e7          	jalr	1344(ra) # 8000612a <uartputc_sync>
    80005bf2:	4521                	li	a0,8
    80005bf4:	00000097          	auipc	ra,0x0
    80005bf8:	536080e7          	jalr	1334(ra) # 8000612a <uartputc_sync>
    80005bfc:	bfe1                	j	80005bd4 <consputc+0x18>

0000000080005bfe <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80005bfe:	1101                	addi	sp,sp,-32
    80005c00:	ec06                	sd	ra,24(sp)
    80005c02:	e822                	sd	s0,16(sp)
    80005c04:	e426                	sd	s1,8(sp)
    80005c06:	e04a                	sd	s2,0(sp)
    80005c08:	1000                	addi	s0,sp,32
    80005c0a:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80005c0c:	0011c517          	auipc	a0,0x11c
    80005c10:	1d450513          	addi	a0,a0,468 # 80121de0 <cons>
    80005c14:	00000097          	auipc	ra,0x0
    80005c18:	7a6080e7          	jalr	1958(ra) # 800063ba <acquire>

  switch(c){
    80005c1c:	47d5                	li	a5,21
    80005c1e:	0af48663          	beq	s1,a5,80005cca <consoleintr+0xcc>
    80005c22:	0297ca63          	blt	a5,s1,80005c56 <consoleintr+0x58>
    80005c26:	47a1                	li	a5,8
    80005c28:	0ef48763          	beq	s1,a5,80005d16 <consoleintr+0x118>
    80005c2c:	47c1                	li	a5,16
    80005c2e:	10f49a63          	bne	s1,a5,80005d42 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    80005c32:	ffffc097          	auipc	ra,0xffffc
    80005c36:	018080e7          	jalr	24(ra) # 80001c4a <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80005c3a:	0011c517          	auipc	a0,0x11c
    80005c3e:	1a650513          	addi	a0,a0,422 # 80121de0 <cons>
    80005c42:	00001097          	auipc	ra,0x1
    80005c46:	82c080e7          	jalr	-2004(ra) # 8000646e <release>
}
    80005c4a:	60e2                	ld	ra,24(sp)
    80005c4c:	6442                	ld	s0,16(sp)
    80005c4e:	64a2                	ld	s1,8(sp)
    80005c50:	6902                	ld	s2,0(sp)
    80005c52:	6105                	addi	sp,sp,32
    80005c54:	8082                	ret
  switch(c){
    80005c56:	07f00793          	li	a5,127
    80005c5a:	0af48e63          	beq	s1,a5,80005d16 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80005c5e:	0011c717          	auipc	a4,0x11c
    80005c62:	18270713          	addi	a4,a4,386 # 80121de0 <cons>
    80005c66:	0a072783          	lw	a5,160(a4)
    80005c6a:	09872703          	lw	a4,152(a4)
    80005c6e:	9f99                	subw	a5,a5,a4
    80005c70:	07f00713          	li	a4,127
    80005c74:	fcf763e3          	bltu	a4,a5,80005c3a <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80005c78:	47b5                	li	a5,13
    80005c7a:	0cf48763          	beq	s1,a5,80005d48 <consoleintr+0x14a>
      consputc(c);
    80005c7e:	8526                	mv	a0,s1
    80005c80:	00000097          	auipc	ra,0x0
    80005c84:	f3c080e7          	jalr	-196(ra) # 80005bbc <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80005c88:	0011c797          	auipc	a5,0x11c
    80005c8c:	15878793          	addi	a5,a5,344 # 80121de0 <cons>
    80005c90:	0a07a683          	lw	a3,160(a5)
    80005c94:	0016871b          	addiw	a4,a3,1
    80005c98:	0007061b          	sext.w	a2,a4
    80005c9c:	0ae7a023          	sw	a4,160(a5)
    80005ca0:	07f6f693          	andi	a3,a3,127
    80005ca4:	97b6                	add	a5,a5,a3
    80005ca6:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80005caa:	47a9                	li	a5,10
    80005cac:	0cf48563          	beq	s1,a5,80005d76 <consoleintr+0x178>
    80005cb0:	4791                	li	a5,4
    80005cb2:	0cf48263          	beq	s1,a5,80005d76 <consoleintr+0x178>
    80005cb6:	0011c797          	auipc	a5,0x11c
    80005cba:	1c27a783          	lw	a5,450(a5) # 80121e78 <cons+0x98>
    80005cbe:	9f1d                	subw	a4,a4,a5
    80005cc0:	08000793          	li	a5,128
    80005cc4:	f6f71be3          	bne	a4,a5,80005c3a <consoleintr+0x3c>
    80005cc8:	a07d                	j	80005d76 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80005cca:	0011c717          	auipc	a4,0x11c
    80005cce:	11670713          	addi	a4,a4,278 # 80121de0 <cons>
    80005cd2:	0a072783          	lw	a5,160(a4)
    80005cd6:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005cda:	0011c497          	auipc	s1,0x11c
    80005cde:	10648493          	addi	s1,s1,262 # 80121de0 <cons>
    while(cons.e != cons.w &&
    80005ce2:	4929                	li	s2,10
    80005ce4:	f4f70be3          	beq	a4,a5,80005c3a <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005ce8:	37fd                	addiw	a5,a5,-1
    80005cea:	07f7f713          	andi	a4,a5,127
    80005cee:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80005cf0:	01874703          	lbu	a4,24(a4)
    80005cf4:	f52703e3          	beq	a4,s2,80005c3a <consoleintr+0x3c>
      cons.e--;
    80005cf8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80005cfc:	10000513          	li	a0,256
    80005d00:	00000097          	auipc	ra,0x0
    80005d04:	ebc080e7          	jalr	-324(ra) # 80005bbc <consputc>
    while(cons.e != cons.w &&
    80005d08:	0a04a783          	lw	a5,160(s1)
    80005d0c:	09c4a703          	lw	a4,156(s1)
    80005d10:	fcf71ce3          	bne	a4,a5,80005ce8 <consoleintr+0xea>
    80005d14:	b71d                	j	80005c3a <consoleintr+0x3c>
    if(cons.e != cons.w){
    80005d16:	0011c717          	auipc	a4,0x11c
    80005d1a:	0ca70713          	addi	a4,a4,202 # 80121de0 <cons>
    80005d1e:	0a072783          	lw	a5,160(a4)
    80005d22:	09c72703          	lw	a4,156(a4)
    80005d26:	f0f70ae3          	beq	a4,a5,80005c3a <consoleintr+0x3c>
      cons.e--;
    80005d2a:	37fd                	addiw	a5,a5,-1
    80005d2c:	0011c717          	auipc	a4,0x11c
    80005d30:	14f72a23          	sw	a5,340(a4) # 80121e80 <cons+0xa0>
      consputc(BACKSPACE);
    80005d34:	10000513          	li	a0,256
    80005d38:	00000097          	auipc	ra,0x0
    80005d3c:	e84080e7          	jalr	-380(ra) # 80005bbc <consputc>
    80005d40:	bded                	j	80005c3a <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80005d42:	ee048ce3          	beqz	s1,80005c3a <consoleintr+0x3c>
    80005d46:	bf21                	j	80005c5e <consoleintr+0x60>
      consputc(c);
    80005d48:	4529                	li	a0,10
    80005d4a:	00000097          	auipc	ra,0x0
    80005d4e:	e72080e7          	jalr	-398(ra) # 80005bbc <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80005d52:	0011c797          	auipc	a5,0x11c
    80005d56:	08e78793          	addi	a5,a5,142 # 80121de0 <cons>
    80005d5a:	0a07a703          	lw	a4,160(a5)
    80005d5e:	0017069b          	addiw	a3,a4,1
    80005d62:	0006861b          	sext.w	a2,a3
    80005d66:	0ad7a023          	sw	a3,160(a5)
    80005d6a:	07f77713          	andi	a4,a4,127
    80005d6e:	97ba                	add	a5,a5,a4
    80005d70:	4729                	li	a4,10
    80005d72:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80005d76:	0011c797          	auipc	a5,0x11c
    80005d7a:	10c7a323          	sw	a2,262(a5) # 80121e7c <cons+0x9c>
        wakeup(&cons.r);
    80005d7e:	0011c517          	auipc	a0,0x11c
    80005d82:	0fa50513          	addi	a0,a0,250 # 80121e78 <cons+0x98>
    80005d86:	ffffc097          	auipc	ra,0xffffc
    80005d8a:	a74080e7          	jalr	-1420(ra) # 800017fa <wakeup>
    80005d8e:	b575                	j	80005c3a <consoleintr+0x3c>

0000000080005d90 <consoleinit>:

void
consoleinit(void)
{
    80005d90:	1141                	addi	sp,sp,-16
    80005d92:	e406                	sd	ra,8(sp)
    80005d94:	e022                	sd	s0,0(sp)
    80005d96:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80005d98:	00003597          	auipc	a1,0x3
    80005d9c:	a9058593          	addi	a1,a1,-1392 # 80008828 <syscalls+0x3f0>
    80005da0:	0011c517          	auipc	a0,0x11c
    80005da4:	04050513          	addi	a0,a0,64 # 80121de0 <cons>
    80005da8:	00000097          	auipc	ra,0x0
    80005dac:	582080e7          	jalr	1410(ra) # 8000632a <initlock>

  uartinit();
    80005db0:	00000097          	auipc	ra,0x0
    80005db4:	32a080e7          	jalr	810(ra) # 800060da <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80005db8:	00113797          	auipc	a5,0x113
    80005dbc:	d5078793          	addi	a5,a5,-688 # 80118b08 <devsw>
    80005dc0:	00000717          	auipc	a4,0x0
    80005dc4:	ce470713          	addi	a4,a4,-796 # 80005aa4 <consoleread>
    80005dc8:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80005dca:	00000717          	auipc	a4,0x0
    80005dce:	c7870713          	addi	a4,a4,-904 # 80005a42 <consolewrite>
    80005dd2:	ef98                	sd	a4,24(a5)
}
    80005dd4:	60a2                	ld	ra,8(sp)
    80005dd6:	6402                	ld	s0,0(sp)
    80005dd8:	0141                	addi	sp,sp,16
    80005dda:	8082                	ret

0000000080005ddc <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80005ddc:	7179                	addi	sp,sp,-48
    80005dde:	f406                	sd	ra,40(sp)
    80005de0:	f022                	sd	s0,32(sp)
    80005de2:	ec26                	sd	s1,24(sp)
    80005de4:	e84a                	sd	s2,16(sp)
    80005de6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    80005de8:	c219                	beqz	a2,80005dee <printint+0x12>
    80005dea:	08054663          	bltz	a0,80005e76 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    80005dee:	2501                	sext.w	a0,a0
    80005df0:	4881                	li	a7,0
    80005df2:	fd040693          	addi	a3,s0,-48

  i = 0;
    80005df6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    80005df8:	2581                	sext.w	a1,a1
    80005dfa:	00003617          	auipc	a2,0x3
    80005dfe:	a5e60613          	addi	a2,a2,-1442 # 80008858 <digits>
    80005e02:	883a                	mv	a6,a4
    80005e04:	2705                	addiw	a4,a4,1
    80005e06:	02b577bb          	remuw	a5,a0,a1
    80005e0a:	1782                	slli	a5,a5,0x20
    80005e0c:	9381                	srli	a5,a5,0x20
    80005e0e:	97b2                	add	a5,a5,a2
    80005e10:	0007c783          	lbu	a5,0(a5)
    80005e14:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    80005e18:	0005079b          	sext.w	a5,a0
    80005e1c:	02b5553b          	divuw	a0,a0,a1
    80005e20:	0685                	addi	a3,a3,1
    80005e22:	feb7f0e3          	bgeu	a5,a1,80005e02 <printint+0x26>

  if(sign)
    80005e26:	00088b63          	beqz	a7,80005e3c <printint+0x60>
    buf[i++] = '-';
    80005e2a:	fe040793          	addi	a5,s0,-32
    80005e2e:	973e                	add	a4,a4,a5
    80005e30:	02d00793          	li	a5,45
    80005e34:	fef70823          	sb	a5,-16(a4)
    80005e38:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80005e3c:	02e05763          	blez	a4,80005e6a <printint+0x8e>
    80005e40:	fd040793          	addi	a5,s0,-48
    80005e44:	00e784b3          	add	s1,a5,a4
    80005e48:	fff78913          	addi	s2,a5,-1
    80005e4c:	993a                	add	s2,s2,a4
    80005e4e:	377d                	addiw	a4,a4,-1
    80005e50:	1702                	slli	a4,a4,0x20
    80005e52:	9301                	srli	a4,a4,0x20
    80005e54:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80005e58:	fff4c503          	lbu	a0,-1(s1)
    80005e5c:	00000097          	auipc	ra,0x0
    80005e60:	d60080e7          	jalr	-672(ra) # 80005bbc <consputc>
  while(--i >= 0)
    80005e64:	14fd                	addi	s1,s1,-1
    80005e66:	ff2499e3          	bne	s1,s2,80005e58 <printint+0x7c>
}
    80005e6a:	70a2                	ld	ra,40(sp)
    80005e6c:	7402                	ld	s0,32(sp)
    80005e6e:	64e2                	ld	s1,24(sp)
    80005e70:	6942                	ld	s2,16(sp)
    80005e72:	6145                	addi	sp,sp,48
    80005e74:	8082                	ret
    x = -xx;
    80005e76:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80005e7a:	4885                	li	a7,1
    x = -xx;
    80005e7c:	bf9d                	j	80005df2 <printint+0x16>

0000000080005e7e <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80005e7e:	1101                	addi	sp,sp,-32
    80005e80:	ec06                	sd	ra,24(sp)
    80005e82:	e822                	sd	s0,16(sp)
    80005e84:	e426                	sd	s1,8(sp)
    80005e86:	1000                	addi	s0,sp,32
    80005e88:	84aa                	mv	s1,a0
  pr.locking = 0;
    80005e8a:	0011c797          	auipc	a5,0x11c
    80005e8e:	0007ab23          	sw	zero,22(a5) # 80121ea0 <pr+0x18>
  printf("panic: ");
    80005e92:	00003517          	auipc	a0,0x3
    80005e96:	99e50513          	addi	a0,a0,-1634 # 80008830 <syscalls+0x3f8>
    80005e9a:	00000097          	auipc	ra,0x0
    80005e9e:	02e080e7          	jalr	46(ra) # 80005ec8 <printf>
  printf(s);
    80005ea2:	8526                	mv	a0,s1
    80005ea4:	00000097          	auipc	ra,0x0
    80005ea8:	024080e7          	jalr	36(ra) # 80005ec8 <printf>
  printf("\n");
    80005eac:	00002517          	auipc	a0,0x2
    80005eb0:	1ac50513          	addi	a0,a0,428 # 80008058 <etext+0x58>
    80005eb4:	00000097          	auipc	ra,0x0
    80005eb8:	014080e7          	jalr	20(ra) # 80005ec8 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80005ebc:	4785                	li	a5,1
    80005ebe:	00003717          	auipc	a4,0x3
    80005ec2:	a4f72f23          	sw	a5,-1442(a4) # 8000891c <panicked>
  for(;;)
    80005ec6:	a001                	j	80005ec6 <panic+0x48>

0000000080005ec8 <printf>:
{
    80005ec8:	7131                	addi	sp,sp,-192
    80005eca:	fc86                	sd	ra,120(sp)
    80005ecc:	f8a2                	sd	s0,112(sp)
    80005ece:	f4a6                	sd	s1,104(sp)
    80005ed0:	f0ca                	sd	s2,96(sp)
    80005ed2:	ecce                	sd	s3,88(sp)
    80005ed4:	e8d2                	sd	s4,80(sp)
    80005ed6:	e4d6                	sd	s5,72(sp)
    80005ed8:	e0da                	sd	s6,64(sp)
    80005eda:	fc5e                	sd	s7,56(sp)
    80005edc:	f862                	sd	s8,48(sp)
    80005ede:	f466                	sd	s9,40(sp)
    80005ee0:	f06a                	sd	s10,32(sp)
    80005ee2:	ec6e                	sd	s11,24(sp)
    80005ee4:	0100                	addi	s0,sp,128
    80005ee6:	8a2a                	mv	s4,a0
    80005ee8:	e40c                	sd	a1,8(s0)
    80005eea:	e810                	sd	a2,16(s0)
    80005eec:	ec14                	sd	a3,24(s0)
    80005eee:	f018                	sd	a4,32(s0)
    80005ef0:	f41c                	sd	a5,40(s0)
    80005ef2:	03043823          	sd	a6,48(s0)
    80005ef6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    80005efa:	0011cd97          	auipc	s11,0x11c
    80005efe:	fa6dad83          	lw	s11,-90(s11) # 80121ea0 <pr+0x18>
  if(locking)
    80005f02:	020d9b63          	bnez	s11,80005f38 <printf+0x70>
  if (fmt == 0)
    80005f06:	040a0263          	beqz	s4,80005f4a <printf+0x82>
  va_start(ap, fmt);
    80005f0a:	00840793          	addi	a5,s0,8
    80005f0e:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80005f12:	000a4503          	lbu	a0,0(s4)
    80005f16:	14050f63          	beqz	a0,80006074 <printf+0x1ac>
    80005f1a:	4981                	li	s3,0
    if(c != '%'){
    80005f1c:	02500a93          	li	s5,37
    switch(c){
    80005f20:	07000b93          	li	s7,112
  consputc('x');
    80005f24:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80005f26:	00003b17          	auipc	s6,0x3
    80005f2a:	932b0b13          	addi	s6,s6,-1742 # 80008858 <digits>
    switch(c){
    80005f2e:	07300c93          	li	s9,115
    80005f32:	06400c13          	li	s8,100
    80005f36:	a82d                	j	80005f70 <printf+0xa8>
    acquire(&pr.lock);
    80005f38:	0011c517          	auipc	a0,0x11c
    80005f3c:	f5050513          	addi	a0,a0,-176 # 80121e88 <pr>
    80005f40:	00000097          	auipc	ra,0x0
    80005f44:	47a080e7          	jalr	1146(ra) # 800063ba <acquire>
    80005f48:	bf7d                	j	80005f06 <printf+0x3e>
    panic("null fmt");
    80005f4a:	00003517          	auipc	a0,0x3
    80005f4e:	8f650513          	addi	a0,a0,-1802 # 80008840 <syscalls+0x408>
    80005f52:	00000097          	auipc	ra,0x0
    80005f56:	f2c080e7          	jalr	-212(ra) # 80005e7e <panic>
      consputc(c);
    80005f5a:	00000097          	auipc	ra,0x0
    80005f5e:	c62080e7          	jalr	-926(ra) # 80005bbc <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80005f62:	2985                	addiw	s3,s3,1
    80005f64:	013a07b3          	add	a5,s4,s3
    80005f68:	0007c503          	lbu	a0,0(a5)
    80005f6c:	10050463          	beqz	a0,80006074 <printf+0x1ac>
    if(c != '%'){
    80005f70:	ff5515e3          	bne	a0,s5,80005f5a <printf+0x92>
    c = fmt[++i] & 0xff;
    80005f74:	2985                	addiw	s3,s3,1
    80005f76:	013a07b3          	add	a5,s4,s3
    80005f7a:	0007c783          	lbu	a5,0(a5)
    80005f7e:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80005f82:	cbed                	beqz	a5,80006074 <printf+0x1ac>
    switch(c){
    80005f84:	05778a63          	beq	a5,s7,80005fd8 <printf+0x110>
    80005f88:	02fbf663          	bgeu	s7,a5,80005fb4 <printf+0xec>
    80005f8c:	09978863          	beq	a5,s9,8000601c <printf+0x154>
    80005f90:	07800713          	li	a4,120
    80005f94:	0ce79563          	bne	a5,a4,8000605e <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80005f98:	f8843783          	ld	a5,-120(s0)
    80005f9c:	00878713          	addi	a4,a5,8
    80005fa0:	f8e43423          	sd	a4,-120(s0)
    80005fa4:	4605                	li	a2,1
    80005fa6:	85ea                	mv	a1,s10
    80005fa8:	4388                	lw	a0,0(a5)
    80005faa:	00000097          	auipc	ra,0x0
    80005fae:	e32080e7          	jalr	-462(ra) # 80005ddc <printint>
      break;
    80005fb2:	bf45                	j	80005f62 <printf+0x9a>
    switch(c){
    80005fb4:	09578f63          	beq	a5,s5,80006052 <printf+0x18a>
    80005fb8:	0b879363          	bne	a5,s8,8000605e <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80005fbc:	f8843783          	ld	a5,-120(s0)
    80005fc0:	00878713          	addi	a4,a5,8
    80005fc4:	f8e43423          	sd	a4,-120(s0)
    80005fc8:	4605                	li	a2,1
    80005fca:	45a9                	li	a1,10
    80005fcc:	4388                	lw	a0,0(a5)
    80005fce:	00000097          	auipc	ra,0x0
    80005fd2:	e0e080e7          	jalr	-498(ra) # 80005ddc <printint>
      break;
    80005fd6:	b771                	j	80005f62 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80005fd8:	f8843783          	ld	a5,-120(s0)
    80005fdc:	00878713          	addi	a4,a5,8
    80005fe0:	f8e43423          	sd	a4,-120(s0)
    80005fe4:	0007b903          	ld	s2,0(a5)
  consputc('0');
    80005fe8:	03000513          	li	a0,48
    80005fec:	00000097          	auipc	ra,0x0
    80005ff0:	bd0080e7          	jalr	-1072(ra) # 80005bbc <consputc>
  consputc('x');
    80005ff4:	07800513          	li	a0,120
    80005ff8:	00000097          	auipc	ra,0x0
    80005ffc:	bc4080e7          	jalr	-1084(ra) # 80005bbc <consputc>
    80006000:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80006002:	03c95793          	srli	a5,s2,0x3c
    80006006:	97da                	add	a5,a5,s6
    80006008:	0007c503          	lbu	a0,0(a5)
    8000600c:	00000097          	auipc	ra,0x0
    80006010:	bb0080e7          	jalr	-1104(ra) # 80005bbc <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80006014:	0912                	slli	s2,s2,0x4
    80006016:	34fd                	addiw	s1,s1,-1
    80006018:	f4ed                	bnez	s1,80006002 <printf+0x13a>
    8000601a:	b7a1                	j	80005f62 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    8000601c:	f8843783          	ld	a5,-120(s0)
    80006020:	00878713          	addi	a4,a5,8
    80006024:	f8e43423          	sd	a4,-120(s0)
    80006028:	6384                	ld	s1,0(a5)
    8000602a:	cc89                	beqz	s1,80006044 <printf+0x17c>
      for(; *s; s++)
    8000602c:	0004c503          	lbu	a0,0(s1)
    80006030:	d90d                	beqz	a0,80005f62 <printf+0x9a>
        consputc(*s);
    80006032:	00000097          	auipc	ra,0x0
    80006036:	b8a080e7          	jalr	-1142(ra) # 80005bbc <consputc>
      for(; *s; s++)
    8000603a:	0485                	addi	s1,s1,1
    8000603c:	0004c503          	lbu	a0,0(s1)
    80006040:	f96d                	bnez	a0,80006032 <printf+0x16a>
    80006042:	b705                	j	80005f62 <printf+0x9a>
        s = "(null)";
    80006044:	00002497          	auipc	s1,0x2
    80006048:	7f448493          	addi	s1,s1,2036 # 80008838 <syscalls+0x400>
      for(; *s; s++)
    8000604c:	02800513          	li	a0,40
    80006050:	b7cd                	j	80006032 <printf+0x16a>
      consputc('%');
    80006052:	8556                	mv	a0,s5
    80006054:	00000097          	auipc	ra,0x0
    80006058:	b68080e7          	jalr	-1176(ra) # 80005bbc <consputc>
      break;
    8000605c:	b719                	j	80005f62 <printf+0x9a>
      consputc('%');
    8000605e:	8556                	mv	a0,s5
    80006060:	00000097          	auipc	ra,0x0
    80006064:	b5c080e7          	jalr	-1188(ra) # 80005bbc <consputc>
      consputc(c);
    80006068:	8526                	mv	a0,s1
    8000606a:	00000097          	auipc	ra,0x0
    8000606e:	b52080e7          	jalr	-1198(ra) # 80005bbc <consputc>
      break;
    80006072:	bdc5                	j	80005f62 <printf+0x9a>
  if(locking)
    80006074:	020d9163          	bnez	s11,80006096 <printf+0x1ce>
}
    80006078:	70e6                	ld	ra,120(sp)
    8000607a:	7446                	ld	s0,112(sp)
    8000607c:	74a6                	ld	s1,104(sp)
    8000607e:	7906                	ld	s2,96(sp)
    80006080:	69e6                	ld	s3,88(sp)
    80006082:	6a46                	ld	s4,80(sp)
    80006084:	6aa6                	ld	s5,72(sp)
    80006086:	6b06                	ld	s6,64(sp)
    80006088:	7be2                	ld	s7,56(sp)
    8000608a:	7c42                	ld	s8,48(sp)
    8000608c:	7ca2                	ld	s9,40(sp)
    8000608e:	7d02                	ld	s10,32(sp)
    80006090:	6de2                	ld	s11,24(sp)
    80006092:	6129                	addi	sp,sp,192
    80006094:	8082                	ret
    release(&pr.lock);
    80006096:	0011c517          	auipc	a0,0x11c
    8000609a:	df250513          	addi	a0,a0,-526 # 80121e88 <pr>
    8000609e:	00000097          	auipc	ra,0x0
    800060a2:	3d0080e7          	jalr	976(ra) # 8000646e <release>
}
    800060a6:	bfc9                	j	80006078 <printf+0x1b0>

00000000800060a8 <printfinit>:
    ;
}

void
printfinit(void)
{
    800060a8:	1101                	addi	sp,sp,-32
    800060aa:	ec06                	sd	ra,24(sp)
    800060ac:	e822                	sd	s0,16(sp)
    800060ae:	e426                	sd	s1,8(sp)
    800060b0:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800060b2:	0011c497          	auipc	s1,0x11c
    800060b6:	dd648493          	addi	s1,s1,-554 # 80121e88 <pr>
    800060ba:	00002597          	auipc	a1,0x2
    800060be:	79658593          	addi	a1,a1,1942 # 80008850 <syscalls+0x418>
    800060c2:	8526                	mv	a0,s1
    800060c4:	00000097          	auipc	ra,0x0
    800060c8:	266080e7          	jalr	614(ra) # 8000632a <initlock>
  pr.locking = 1;
    800060cc:	4785                	li	a5,1
    800060ce:	cc9c                	sw	a5,24(s1)
}
    800060d0:	60e2                	ld	ra,24(sp)
    800060d2:	6442                	ld	s0,16(sp)
    800060d4:	64a2                	ld	s1,8(sp)
    800060d6:	6105                	addi	sp,sp,32
    800060d8:	8082                	ret

00000000800060da <uartinit>:

void uartstart();

void
uartinit(void)
{
    800060da:	1141                	addi	sp,sp,-16
    800060dc:	e406                	sd	ra,8(sp)
    800060de:	e022                	sd	s0,0(sp)
    800060e0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800060e2:	100007b7          	lui	a5,0x10000
    800060e6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800060ea:	f8000713          	li	a4,-128
    800060ee:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800060f2:	470d                	li	a4,3
    800060f4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800060f8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800060fc:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80006100:	469d                	li	a3,7
    80006102:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80006106:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    8000610a:	00002597          	auipc	a1,0x2
    8000610e:	76658593          	addi	a1,a1,1894 # 80008870 <digits+0x18>
    80006112:	0011c517          	auipc	a0,0x11c
    80006116:	d9650513          	addi	a0,a0,-618 # 80121ea8 <uart_tx_lock>
    8000611a:	00000097          	auipc	ra,0x0
    8000611e:	210080e7          	jalr	528(ra) # 8000632a <initlock>
}
    80006122:	60a2                	ld	ra,8(sp)
    80006124:	6402                	ld	s0,0(sp)
    80006126:	0141                	addi	sp,sp,16
    80006128:	8082                	ret

000000008000612a <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000612a:	1101                	addi	sp,sp,-32
    8000612c:	ec06                	sd	ra,24(sp)
    8000612e:	e822                	sd	s0,16(sp)
    80006130:	e426                	sd	s1,8(sp)
    80006132:	1000                	addi	s0,sp,32
    80006134:	84aa                	mv	s1,a0
  push_off();
    80006136:	00000097          	auipc	ra,0x0
    8000613a:	238080e7          	jalr	568(ra) # 8000636e <push_off>

  if(panicked){
    8000613e:	00002797          	auipc	a5,0x2
    80006142:	7de7a783          	lw	a5,2014(a5) # 8000891c <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80006146:	10000737          	lui	a4,0x10000
  if(panicked){
    8000614a:	c391                	beqz	a5,8000614e <uartputc_sync+0x24>
    for(;;)
    8000614c:	a001                	j	8000614c <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000614e:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80006152:	0207f793          	andi	a5,a5,32
    80006156:	dfe5                	beqz	a5,8000614e <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80006158:	0ff4f513          	andi	a0,s1,255
    8000615c:	100007b7          	lui	a5,0x10000
    80006160:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80006164:	00000097          	auipc	ra,0x0
    80006168:	2aa080e7          	jalr	682(ra) # 8000640e <pop_off>
}
    8000616c:	60e2                	ld	ra,24(sp)
    8000616e:	6442                	ld	s0,16(sp)
    80006170:	64a2                	ld	s1,8(sp)
    80006172:	6105                	addi	sp,sp,32
    80006174:	8082                	ret

0000000080006176 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80006176:	00002797          	auipc	a5,0x2
    8000617a:	7aa7b783          	ld	a5,1962(a5) # 80008920 <uart_tx_r>
    8000617e:	00002717          	auipc	a4,0x2
    80006182:	7aa73703          	ld	a4,1962(a4) # 80008928 <uart_tx_w>
    80006186:	06f70a63          	beq	a4,a5,800061fa <uartstart+0x84>
{
    8000618a:	7139                	addi	sp,sp,-64
    8000618c:	fc06                	sd	ra,56(sp)
    8000618e:	f822                	sd	s0,48(sp)
    80006190:	f426                	sd	s1,40(sp)
    80006192:	f04a                	sd	s2,32(sp)
    80006194:	ec4e                	sd	s3,24(sp)
    80006196:	e852                	sd	s4,16(sp)
    80006198:	e456                	sd	s5,8(sp)
    8000619a:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000619c:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800061a0:	0011ca17          	auipc	s4,0x11c
    800061a4:	d08a0a13          	addi	s4,s4,-760 # 80121ea8 <uart_tx_lock>
    uart_tx_r += 1;
    800061a8:	00002497          	auipc	s1,0x2
    800061ac:	77848493          	addi	s1,s1,1912 # 80008920 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    800061b0:	00002997          	auipc	s3,0x2
    800061b4:	77898993          	addi	s3,s3,1912 # 80008928 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800061b8:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    800061bc:	02077713          	andi	a4,a4,32
    800061c0:	c705                	beqz	a4,800061e8 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800061c2:	01f7f713          	andi	a4,a5,31
    800061c6:	9752                	add	a4,a4,s4
    800061c8:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    800061cc:	0785                	addi	a5,a5,1
    800061ce:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800061d0:	8526                	mv	a0,s1
    800061d2:	ffffb097          	auipc	ra,0xffffb
    800061d6:	628080e7          	jalr	1576(ra) # 800017fa <wakeup>
    
    WriteReg(THR, c);
    800061da:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800061de:	609c                	ld	a5,0(s1)
    800061e0:	0009b703          	ld	a4,0(s3)
    800061e4:	fcf71ae3          	bne	a4,a5,800061b8 <uartstart+0x42>
  }
}
    800061e8:	70e2                	ld	ra,56(sp)
    800061ea:	7442                	ld	s0,48(sp)
    800061ec:	74a2                	ld	s1,40(sp)
    800061ee:	7902                	ld	s2,32(sp)
    800061f0:	69e2                	ld	s3,24(sp)
    800061f2:	6a42                	ld	s4,16(sp)
    800061f4:	6aa2                	ld	s5,8(sp)
    800061f6:	6121                	addi	sp,sp,64
    800061f8:	8082                	ret
    800061fa:	8082                	ret

00000000800061fc <uartputc>:
{
    800061fc:	7179                	addi	sp,sp,-48
    800061fe:	f406                	sd	ra,40(sp)
    80006200:	f022                	sd	s0,32(sp)
    80006202:	ec26                	sd	s1,24(sp)
    80006204:	e84a                	sd	s2,16(sp)
    80006206:	e44e                	sd	s3,8(sp)
    80006208:	e052                	sd	s4,0(sp)
    8000620a:	1800                	addi	s0,sp,48
    8000620c:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000620e:	0011c517          	auipc	a0,0x11c
    80006212:	c9a50513          	addi	a0,a0,-870 # 80121ea8 <uart_tx_lock>
    80006216:	00000097          	auipc	ra,0x0
    8000621a:	1a4080e7          	jalr	420(ra) # 800063ba <acquire>
  if(panicked){
    8000621e:	00002797          	auipc	a5,0x2
    80006222:	6fe7a783          	lw	a5,1790(a5) # 8000891c <panicked>
    80006226:	e7c9                	bnez	a5,800062b0 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80006228:	00002717          	auipc	a4,0x2
    8000622c:	70073703          	ld	a4,1792(a4) # 80008928 <uart_tx_w>
    80006230:	00002797          	auipc	a5,0x2
    80006234:	6f07b783          	ld	a5,1776(a5) # 80008920 <uart_tx_r>
    80006238:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000623c:	0011c997          	auipc	s3,0x11c
    80006240:	c6c98993          	addi	s3,s3,-916 # 80121ea8 <uart_tx_lock>
    80006244:	00002497          	auipc	s1,0x2
    80006248:	6dc48493          	addi	s1,s1,1756 # 80008920 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000624c:	00002917          	auipc	s2,0x2
    80006250:	6dc90913          	addi	s2,s2,1756 # 80008928 <uart_tx_w>
    80006254:	00e79f63          	bne	a5,a4,80006272 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80006258:	85ce                	mv	a1,s3
    8000625a:	8526                	mv	a0,s1
    8000625c:	ffffb097          	auipc	ra,0xffffb
    80006260:	53a080e7          	jalr	1338(ra) # 80001796 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80006264:	00093703          	ld	a4,0(s2)
    80006268:	609c                	ld	a5,0(s1)
    8000626a:	02078793          	addi	a5,a5,32
    8000626e:	fee785e3          	beq	a5,a4,80006258 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80006272:	0011c497          	auipc	s1,0x11c
    80006276:	c3648493          	addi	s1,s1,-970 # 80121ea8 <uart_tx_lock>
    8000627a:	01f77793          	andi	a5,a4,31
    8000627e:	97a6                	add	a5,a5,s1
    80006280:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80006284:	0705                	addi	a4,a4,1
    80006286:	00002797          	auipc	a5,0x2
    8000628a:	6ae7b123          	sd	a4,1698(a5) # 80008928 <uart_tx_w>
  uartstart();
    8000628e:	00000097          	auipc	ra,0x0
    80006292:	ee8080e7          	jalr	-280(ra) # 80006176 <uartstart>
  release(&uart_tx_lock);
    80006296:	8526                	mv	a0,s1
    80006298:	00000097          	auipc	ra,0x0
    8000629c:	1d6080e7          	jalr	470(ra) # 8000646e <release>
}
    800062a0:	70a2                	ld	ra,40(sp)
    800062a2:	7402                	ld	s0,32(sp)
    800062a4:	64e2                	ld	s1,24(sp)
    800062a6:	6942                	ld	s2,16(sp)
    800062a8:	69a2                	ld	s3,8(sp)
    800062aa:	6a02                	ld	s4,0(sp)
    800062ac:	6145                	addi	sp,sp,48
    800062ae:	8082                	ret
    for(;;)
    800062b0:	a001                	j	800062b0 <uartputc+0xb4>

00000000800062b2 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800062b2:	1141                	addi	sp,sp,-16
    800062b4:	e422                	sd	s0,8(sp)
    800062b6:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800062b8:	100007b7          	lui	a5,0x10000
    800062bc:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800062c0:	8b85                	andi	a5,a5,1
    800062c2:	cb91                	beqz	a5,800062d6 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800062c4:	100007b7          	lui	a5,0x10000
    800062c8:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800062cc:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    800062d0:	6422                	ld	s0,8(sp)
    800062d2:	0141                	addi	sp,sp,16
    800062d4:	8082                	ret
    return -1;
    800062d6:	557d                	li	a0,-1
    800062d8:	bfe5                	j	800062d0 <uartgetc+0x1e>

00000000800062da <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800062da:	1101                	addi	sp,sp,-32
    800062dc:	ec06                	sd	ra,24(sp)
    800062de:	e822                	sd	s0,16(sp)
    800062e0:	e426                	sd	s1,8(sp)
    800062e2:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800062e4:	54fd                	li	s1,-1
    800062e6:	a029                	j	800062f0 <uartintr+0x16>
      break;
    consoleintr(c);
    800062e8:	00000097          	auipc	ra,0x0
    800062ec:	916080e7          	jalr	-1770(ra) # 80005bfe <consoleintr>
    int c = uartgetc();
    800062f0:	00000097          	auipc	ra,0x0
    800062f4:	fc2080e7          	jalr	-62(ra) # 800062b2 <uartgetc>
    if(c == -1)
    800062f8:	fe9518e3          	bne	a0,s1,800062e8 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800062fc:	0011c497          	auipc	s1,0x11c
    80006300:	bac48493          	addi	s1,s1,-1108 # 80121ea8 <uart_tx_lock>
    80006304:	8526                	mv	a0,s1
    80006306:	00000097          	auipc	ra,0x0
    8000630a:	0b4080e7          	jalr	180(ra) # 800063ba <acquire>
  uartstart();
    8000630e:	00000097          	auipc	ra,0x0
    80006312:	e68080e7          	jalr	-408(ra) # 80006176 <uartstart>
  release(&uart_tx_lock);
    80006316:	8526                	mv	a0,s1
    80006318:	00000097          	auipc	ra,0x0
    8000631c:	156080e7          	jalr	342(ra) # 8000646e <release>
}
    80006320:	60e2                	ld	ra,24(sp)
    80006322:	6442                	ld	s0,16(sp)
    80006324:	64a2                	ld	s1,8(sp)
    80006326:	6105                	addi	sp,sp,32
    80006328:	8082                	ret

000000008000632a <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    8000632a:	1141                	addi	sp,sp,-16
    8000632c:	e422                	sd	s0,8(sp)
    8000632e:	0800                	addi	s0,sp,16
  lk->name = name;
    80006330:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80006332:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80006336:	00053823          	sd	zero,16(a0)
}
    8000633a:	6422                	ld	s0,8(sp)
    8000633c:	0141                	addi	sp,sp,16
    8000633e:	8082                	ret

0000000080006340 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80006340:	411c                	lw	a5,0(a0)
    80006342:	e399                	bnez	a5,80006348 <holding+0x8>
    80006344:	4501                	li	a0,0
  return r;
}
    80006346:	8082                	ret
{
    80006348:	1101                	addi	sp,sp,-32
    8000634a:	ec06                	sd	ra,24(sp)
    8000634c:	e822                	sd	s0,16(sp)
    8000634e:	e426                	sd	s1,8(sp)
    80006350:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80006352:	6904                	ld	s1,16(a0)
    80006354:	ffffb097          	auipc	ra,0xffffb
    80006358:	d7a080e7          	jalr	-646(ra) # 800010ce <mycpu>
    8000635c:	40a48533          	sub	a0,s1,a0
    80006360:	00153513          	seqz	a0,a0
}
    80006364:	60e2                	ld	ra,24(sp)
    80006366:	6442                	ld	s0,16(sp)
    80006368:	64a2                	ld	s1,8(sp)
    8000636a:	6105                	addi	sp,sp,32
    8000636c:	8082                	ret

000000008000636e <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    8000636e:	1101                	addi	sp,sp,-32
    80006370:	ec06                	sd	ra,24(sp)
    80006372:	e822                	sd	s0,16(sp)
    80006374:	e426                	sd	s1,8(sp)
    80006376:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80006378:	100024f3          	csrr	s1,sstatus
    8000637c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80006380:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80006382:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80006386:	ffffb097          	auipc	ra,0xffffb
    8000638a:	d48080e7          	jalr	-696(ra) # 800010ce <mycpu>
    8000638e:	5d3c                	lw	a5,120(a0)
    80006390:	cf89                	beqz	a5,800063aa <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80006392:	ffffb097          	auipc	ra,0xffffb
    80006396:	d3c080e7          	jalr	-708(ra) # 800010ce <mycpu>
    8000639a:	5d3c                	lw	a5,120(a0)
    8000639c:	2785                	addiw	a5,a5,1
    8000639e:	dd3c                	sw	a5,120(a0)
}
    800063a0:	60e2                	ld	ra,24(sp)
    800063a2:	6442                	ld	s0,16(sp)
    800063a4:	64a2                	ld	s1,8(sp)
    800063a6:	6105                	addi	sp,sp,32
    800063a8:	8082                	ret
    mycpu()->intena = old;
    800063aa:	ffffb097          	auipc	ra,0xffffb
    800063ae:	d24080e7          	jalr	-732(ra) # 800010ce <mycpu>
  return (x & SSTATUS_SIE) != 0;
    800063b2:	8085                	srli	s1,s1,0x1
    800063b4:	8885                	andi	s1,s1,1
    800063b6:	dd64                	sw	s1,124(a0)
    800063b8:	bfe9                	j	80006392 <push_off+0x24>

00000000800063ba <acquire>:
{
    800063ba:	1101                	addi	sp,sp,-32
    800063bc:	ec06                	sd	ra,24(sp)
    800063be:	e822                	sd	s0,16(sp)
    800063c0:	e426                	sd	s1,8(sp)
    800063c2:	1000                	addi	s0,sp,32
    800063c4:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    800063c6:	00000097          	auipc	ra,0x0
    800063ca:	fa8080e7          	jalr	-88(ra) # 8000636e <push_off>
  if(holding(lk))
    800063ce:	8526                	mv	a0,s1
    800063d0:	00000097          	auipc	ra,0x0
    800063d4:	f70080e7          	jalr	-144(ra) # 80006340 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    800063d8:	4705                	li	a4,1
  if(holding(lk))
    800063da:	e115                	bnez	a0,800063fe <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    800063dc:	87ba                	mv	a5,a4
    800063de:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    800063e2:	2781                	sext.w	a5,a5
    800063e4:	ffe5                	bnez	a5,800063dc <acquire+0x22>
  __sync_synchronize();
    800063e6:	0ff0000f          	fence
  lk->cpu = mycpu();
    800063ea:	ffffb097          	auipc	ra,0xffffb
    800063ee:	ce4080e7          	jalr	-796(ra) # 800010ce <mycpu>
    800063f2:	e888                	sd	a0,16(s1)
}
    800063f4:	60e2                	ld	ra,24(sp)
    800063f6:	6442                	ld	s0,16(sp)
    800063f8:	64a2                	ld	s1,8(sp)
    800063fa:	6105                	addi	sp,sp,32
    800063fc:	8082                	ret
    panic("acquire");
    800063fe:	00002517          	auipc	a0,0x2
    80006402:	47a50513          	addi	a0,a0,1146 # 80008878 <digits+0x20>
    80006406:	00000097          	auipc	ra,0x0
    8000640a:	a78080e7          	jalr	-1416(ra) # 80005e7e <panic>

000000008000640e <pop_off>:

void
pop_off(void)
{
    8000640e:	1141                	addi	sp,sp,-16
    80006410:	e406                	sd	ra,8(sp)
    80006412:	e022                	sd	s0,0(sp)
    80006414:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80006416:	ffffb097          	auipc	ra,0xffffb
    8000641a:	cb8080e7          	jalr	-840(ra) # 800010ce <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000641e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80006422:	8b89                	andi	a5,a5,2
  if(intr_get())
    80006424:	e78d                	bnez	a5,8000644e <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80006426:	5d3c                	lw	a5,120(a0)
    80006428:	02f05b63          	blez	a5,8000645e <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    8000642c:	37fd                	addiw	a5,a5,-1
    8000642e:	0007871b          	sext.w	a4,a5
    80006432:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80006434:	eb09                	bnez	a4,80006446 <pop_off+0x38>
    80006436:	5d7c                	lw	a5,124(a0)
    80006438:	c799                	beqz	a5,80006446 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000643a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000643e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80006442:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80006446:	60a2                	ld	ra,8(sp)
    80006448:	6402                	ld	s0,0(sp)
    8000644a:	0141                	addi	sp,sp,16
    8000644c:	8082                	ret
    panic("pop_off - interruptible");
    8000644e:	00002517          	auipc	a0,0x2
    80006452:	43250513          	addi	a0,a0,1074 # 80008880 <digits+0x28>
    80006456:	00000097          	auipc	ra,0x0
    8000645a:	a28080e7          	jalr	-1496(ra) # 80005e7e <panic>
    panic("pop_off");
    8000645e:	00002517          	auipc	a0,0x2
    80006462:	43a50513          	addi	a0,a0,1082 # 80008898 <digits+0x40>
    80006466:	00000097          	auipc	ra,0x0
    8000646a:	a18080e7          	jalr	-1512(ra) # 80005e7e <panic>

000000008000646e <release>:
{
    8000646e:	1101                	addi	sp,sp,-32
    80006470:	ec06                	sd	ra,24(sp)
    80006472:	e822                	sd	s0,16(sp)
    80006474:	e426                	sd	s1,8(sp)
    80006476:	1000                	addi	s0,sp,32
    80006478:	84aa                	mv	s1,a0
  if(!holding(lk))
    8000647a:	00000097          	auipc	ra,0x0
    8000647e:	ec6080e7          	jalr	-314(ra) # 80006340 <holding>
    80006482:	c115                	beqz	a0,800064a6 <release+0x38>
  lk->cpu = 0;
    80006484:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80006488:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    8000648c:	0f50000f          	fence	iorw,ow
    80006490:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80006494:	00000097          	auipc	ra,0x0
    80006498:	f7a080e7          	jalr	-134(ra) # 8000640e <pop_off>
}
    8000649c:	60e2                	ld	ra,24(sp)
    8000649e:	6442                	ld	s0,16(sp)
    800064a0:	64a2                	ld	s1,8(sp)
    800064a2:	6105                	addi	sp,sp,32
    800064a4:	8082                	ret
    panic("release");
    800064a6:	00002517          	auipc	a0,0x2
    800064aa:	3fa50513          	addi	a0,a0,1018 # 800088a0 <digits+0x48>
    800064ae:	00000097          	auipc	ra,0x0
    800064b2:	9d0080e7          	jalr	-1584(ra) # 80005e7e <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
