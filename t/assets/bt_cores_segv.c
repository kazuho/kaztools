static void foo(void)
{
  *(char*)1 = 1;
}

int main(int argc, char** argv)
{
  foo();
  return 0;
}
