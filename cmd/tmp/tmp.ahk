void TestFunc_(unsigned int n)
{
	int (*p)[5] = new int[n][5];//分配10个int[5]类型的空间
	delete[] p;
}
void TestFunc_pointer(unsigned int height, unsigned int width)
{
	//分配的数组空间不连续
	int **p = new int*[height];
	for (int i = 0; i < height; i++)
	{
		p[i] = new int[width];
	}

	for (int i = 0; i < height; i++)
	{
		delete[] p[i];
	}
	delete[] p;
}
void TestFunc_vector(unsigned int height, unsigned int width)
{
	vector<vector<int>> * p = new vector<vector<int>>;
	p->reserve(height);
	for (int i = 0; i < height; i++)
	{
		p[i].reserve(width);
	}
	delete p;
}
void test_create_2d_vector(unsigned int height, unsigned int width)
{
	vector <vector<int>> vector_2d(height, vector<int>(width,2));
	std::cout << vector_2d[3][3];
}