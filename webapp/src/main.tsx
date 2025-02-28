import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { Provider } from '@/components/ui/provider';
import { Center, VStack } from '@chakra-ui/react';
import { Footer } from '@/components/Footer';
import { Navbar } from '@/components/Navbar';
import { App } from '@/App';

const queryClient = new QueryClient();

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <QueryClientProvider client={queryClient}>
      <Provider>
        <VStack h="100vh" w="100vw" padding={8} paddingBottom={4}>
          <Navbar />
          <Center flexGrow={1} w="100%" padding="1rem 0">
            <App />
          </Center>
          <Footer />
        </VStack>
      </Provider>
    </QueryClientProvider>
  </StrictMode>
);
