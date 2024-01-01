// Physical memory allocator, for user processes,
// kernel stacks, page-table pages,
// and pipe buffers. Allocates whole 4096-byte pages.

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"

void freerange(void *pa_start, void *pa_end);

extern char end[]; // first address after kernel.
                   // defined by kernel.ld.

struct run {
  struct run *next;
};

struct {
  struct spinlock lock;
  struct run *freelist;
} kmem;


// 引用计数器结构
typedef struct
{
  struct spinlock lock;// 在这个实验里锁不是必须的，不加锁也能通过实验
  uint8 count;
} reference;

// 引用计数器数组
reference phypgrefer[(PHYSTOP - KERNBASE) / PGSIZE + 10];

// 获取物理页索引
#define PG_IDX(pa) ((pa - KERNBASE) / PGSIZE)


// void
// kinit()
// {
//   initlock(&kmem.lock, "kmem");
//   freerange(end, (void*)PHYSTOP);
// }


void kinit()
{
  initlock(&kmem.lock, "kmem");
  for (int i = 0; i < (PHYSTOP - KERNBASE) / PGSIZE + 10; i++)
  {
    initlock(&(phypgrefer[i].lock), "phymem_ref");//初始化锁
  }
  freerange(end, (void *)PHYSTOP);
}

// void
// freerange(void *pa_start, void *pa_end)
// {
//   char *p;
//   p = (char*)PGROUNDUP((uint64)pa_start);
//   for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
//     kfree(p);
// }

void freerange(void *pa_start, void *pa_end)
{
  char *p;
  p = (char *)PGROUNDUP((uint64)pa_start);

  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
  {
    phypgrefer[PG_IDX((uint64)p)].count = 0;
    kfree(p);
  }
}


// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)

// void
// kfree(void *pa)
// {
//   struct run *r;

//   if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
//     panic("kfree");

//   // Fill with junk to catch dangling refs.
//   memset(pa, 1, PGSIZE);

//   r = (struct run*)pa;

//   acquire(&kmem.lock);
//   r->next = kmem.freelist;
//   kmem.freelist = r;
//   release(&kmem.lock);
// }

void kfree(void *pa)
{
  struct run *r;

  if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    panic("kfree");
  acquire(&phypgrefer[PG_IDX((uint64)pa)].lock);
  if (phypgrefer[PG_IDX((uint64)pa)].count > 0)
    phypgrefer[PG_IDX((uint64)pa)].count -= 1;
  if (phypgrefer[PG_IDX((uint64)pa)].count != 0)// 当此物理地址没有逻辑地址引用时才可以释放该物理地址
  {
    release(&phypgrefer[PG_IDX((uint64)pa)].lock);
    return;
  }
  release(&phypgrefer[PG_IDX((uint64)pa)].lock);

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);

  r = (struct run *)pa;

  acquire(&kmem.lock);
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
}

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.

// void *
// kalloc(void)
// {
//   struct run *r;

//   acquire(&kmem.lock);
//   r = kmem.freelist;
//   if(r)
//     kmem.freelist = r->next;
//   release(&kmem.lock);

//   if(r)
//     memset((char*)r, 5, PGSIZE); // fill with junk
//   return (void*)r;
// }

void *
kalloc(void)
{
  struct run *r;

  acquire(&kmem.lock);
  r = kmem.freelist;
  if (r)
    kmem.freelist = r->next;
  release(&kmem.lock);

  if (r)
  {
    memset((char *)r, 5, PGSIZE); // fill with junk
    acquire(&phypgrefer[PG_IDX((uint64)r)].lock);//分配页面时将计数初始化为1
    phypgrefer[PG_IDX((uint64)r)].count = 1;
    release(&phypgrefer[PG_IDX((uint64)r)].lock);
  }
  return (void *)r;
}

// 当一个物理页面新增一个逻辑页面引用它时其引用计数值加1
int add_refer(uint64 pa)
{
  if ((uint64)pa % PGSIZE != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
  {
    return -1;
  }
  acquire(&phypgrefer[PG_IDX((uint64)pa)].lock);
  phypgrefer[PG_IDX((uint64)pa)].count += 1;
  release(&phypgrefer[PG_IDX((uint64)pa)].lock);
  return 0;
}
